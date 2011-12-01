//
//  OpenGLView.m
//  OpenGLES2Test
//
//  Created by hx on 10/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"
#import "CC3GLMatrix.h"
#import <math.h>
#define PIE_LABEL_TAG_BASE 11

@implementation OpenGLView

+(Class)layerClass{
    return [CAEAGLLayer class];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        

        [self setupLayer];        
        [self setupContext];
        [self setupRenderBuffer];
        [self compileShaders];
        
        _shadowTexture = [self setupTexture:@"shadow.png"];
        _rotatePieX = 40.0;
    }
    return self;
}

-(void)setupPartData:(float *)partData :(float *)partGreenData :(float *)partYellowData{
    
    for (int i=0; i<PARTNUM; i++) {
        partValue[i]    = partData[i];
        float totalPercent = partGreenData[i]+partYellowData[i];
        if(totalPercent!=0){
            partMarkedGreenValue[i]    = sqrtf(partGreenData[i]);
            partMarkedYellowValue[i]   = sqrtf(partGreenData[i]+partYellowData[i])-partMarkedGreenValue[i];
        }else{
            partMarkedGreenValue[i]    = 0;
            partMarkedYellowValue[i]   = 0;
        }
    }
    
    buildModel();
    [self setupVBOs];
}

-(void)setupLayer{
    _eaglLayer  = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque   = NO;
}


- (void)setupTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(1.0 / 30.0)
                                              target:self
                                            selector:@selector(render:)
                                            userInfo:nil
                                             repeats:TRUE];
}

- (void)destroyTimer{
    if (_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)setupContext{
    EAGLRenderingAPI api    = kEAGLRenderingAPIOpenGLES2;
    _context    = [[EAGLContext alloc] initWithAPI:api];
    if(!_context){
        NSLog(@"Failed to intialize OpenGLES 2.0 context");
        exit(1);
    }
    if(![EAGLContext setCurrentContext:_context]){
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}


- (GLuint)setupTexture:(NSString *)fileName {    
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }

    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, 
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); 
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return texName;
}



- (void)setupRenderBuffer {
    _msaaSample = 2;
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_depthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
    
    glGenRenderbuffers(1, &_colorBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBuffer);
    
    glGenFramebuffers(1, &_msaaFrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _msaaFrameBuffer);
    
    glGenRenderbuffers(1, &_msaaColorBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _msaaColorBuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _msaaSample, GL_RGBA8_OES, self.frame.size.width, self.frame.size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaColorBuffer);
    
    glGenRenderbuffers(1, &_msaaDepthBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _msaaDepthBuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _msaaSample, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
    
    glEnable(GL_DEPTH_TEST);
}



- (void)setupVBOs {
    glGenBuffers(1, &_pieVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _pieVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(pieVertices), pieVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_pieIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _pieIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(pieIndices), pieIndices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_shadowVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _shadowVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(shadowVertices), shadowVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_shadowIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _shadowIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(shadowIndices), shadowIndices, GL_STATIC_DRAW);

}

-(void)gotoPart:(int)partId{
    float startPartVal  = 0;
    float endPartVal    = 0;
    for(int i=0;i<partId;i++){
        startPartVal    += partValue[i];
    }
    endPartVal          = startPartVal+ partValue[partId];
    
    float ang           = (startPartVal+endPartVal)/2 *360+180;
    _currentRotatePieY  = (int)_currentRotatePieY % 360;
    
    if(abs(ang-_currentRotatePieY)<180){
        _rotatePieY     = ang;
    }else if(ang-_currentRotatePieY<-180){
        _rotatePieY     = ang+360;
    }else{
        _rotatePieY     = ang-360;
    }
}



- (void)render:(CADisplayLink*)displayLink {
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glBindFramebuffer(GL_FRAMEBUFFER, _msaaFrameBuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDisable(GL_BLEND);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    
    
    CC3GLMatrix *projection  = [CC3GLMatrix matrix];

    [projection populateFromFrustumLeft:-1 andRight:1 andBottom:-1 andTop:1 andNear:2 andFar:8];
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(0, 0, -6)];
    _currentRotatePieX  += (_rotatePieX-_currentRotatePieX)/4;
    _currentRotatePieY  += (_rotatePieY-_currentRotatePieY)/4;
    
    [modelView rotateByX:_currentRotatePieX];
    [modelView rotateByY:_currentRotatePieY];
    [projection multiplyByMatrix:modelView];
    
    glUseProgram(_pieProgramHandle);
    glUniformMatrix4fv(_pieProjectMtxUniform, 1, 0, projection.glMatrix);
    glUniformMatrix4fv(_pieModelViewMtxUniform,1, 0, modelView.glMatrix);

    CC3GLMatrix *normalMtx = [CC3GLMatrix matrix];
    [normalMtx populateIdentity];
    [normalMtx rotateByX:_currentRotatePieX];
    [normalMtx rotateByY:_currentRotatePieY];

    glUniformMatrix4fv(_pieNormalMtxUniform,1, 0, normalMtx.glMatrix);

    glUniform4f(_pieLightDirectionnUniform, lightDirection[0], lightDirection[1], lightDirection[2],1);
    glBindBuffer(GL_ARRAY_BUFFER, _pieVertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _pieIndexBuffer);
    
    
    glVertexAttribPointer(_piePositionSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_pieColorSlot, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_pieNormalSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7)); 
    glVertexAttribPointer(_pieTexCoordSlot, 2, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 10));    
    
    glActiveTexture(GL_TEXTURE0); 
    glUniform1i(_pieTextureUniform, 0);

    glDrawElements(GL_TRIANGLES, sizeof(pieIndices)/sizeof(pieIndices[0]), 
                   GL_UNSIGNED_SHORT, 0);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(_shadowProgramHandle);
    
    glUniformMatrix4fv(_shadowProjectionUniform, 1, 0, projection.glMatrix);
    
    glBindBuffer(GL_ARRAY_BUFFER, _shadowVertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _shadowIndexBuffer);
    
    
    glVertexAttribPointer(_shadowPositionSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_shadowColorSlot, 4, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    glVertexAttribPointer(_shadowNormalSlot, 3, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 7)); 
    glVertexAttribPointer(_shadowTexCoordSlot, 2, GL_FLOAT, GL_FALSE, 
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 10));    
    
    glActiveTexture(GL_TEXTURE0); 
    glBindTexture(GL_TEXTURE_2D, _shadowTexture);
    glUniform1i(_shadowTextureUniform, 0);
    
    
    glDrawElements(GL_TRIANGLES, sizeof(shadowIndices)/sizeof(shadowIndices[0]), 
                   GL_UNSIGNED_SHORT, 0);
    
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _frameBuffer);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFrameBuffer);
    glResolveMultisampleFramebufferAPPLE();
    GLenum attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    float startPartVal  = 0;
    float endPartVal    = 0;
    float diffX         = self.frame.origin.x+self.frame.size.width/2;
    float diffY         = self.frame.origin.y+self.frame.size.height/2;
    for(int i=0;i<PARTNUM;i++){
        endPartVal          += partValue[i];
        UIImageView *pieLabel = (UIImageView *)[self.superview viewWithTag:PIE_LABEL_TAG_BASE+i];
        CC3Vector      labelPosition;
        float ang       = (startPartVal+endPartVal)/2 *PI2;
        labelPosition.x = sinf(ang);
        labelPosition.y = .25;
        labelPosition.z = -cosf(ang);
        CC3Vector labelProjPosition    = [projection transformLocation:labelPosition];
        pieLabel.frame = CGRectMake(diffX+labelProjPosition.x*320-8, diffY-labelProjPosition.y*320-pieLabel.image.size.height, pieLabel.image.size.width, pieLabel.image.size.height);
        
        startPartVal    += partValue[i];
    }
}



- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {

    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    GLuint shaderHandle = glCreateShader(shaderType);    
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
    
}



- (void)compileShaders {
    GLuint vertexShader = [self compileShader:@"PieVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"PieFragment" withType:GL_FRAGMENT_SHADER];

    _pieProgramHandle = glCreateProgram();
    glAttachShader(_pieProgramHandle, vertexShader);
    glAttachShader(_pieProgramHandle, fragmentShader);
    glLinkProgram(_pieProgramHandle);
    
    GLint linkSuccess;
    glGetProgramiv(_pieProgramHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_pieProgramHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    _piePositionSlot   = glGetAttribLocation(_pieProgramHandle, "Position");
    _pieColorSlot      = glGetAttribLocation(_pieProgramHandle, "SourceColor");
    _pieTexCoordSlot   = glGetAttribLocation(_pieProgramHandle, "TexCoordIn");
    _pieNormalSlot     = glGetAttribLocation(_pieProgramHandle, "NormalIn");
         
    glEnableVertexAttribArray(_piePositionSlot);
    glEnableVertexAttribArray(_pieColorSlot);
    glEnableVertexAttribArray(_pieTexCoordSlot);
    glEnableVertexAttribArray(_pieNormalSlot);
    
    _pieProjectMtxUniform      = glGetUniformLocation(_pieProgramHandle, "ProjectionMtx");
    _pieNormalMtxUniform       = glGetUniformLocation(_pieProgramHandle, "normalMtx");
    _pieModelViewMtxUniform    = glGetUniformLocation(_pieProgramHandle, "modelViewMtx");
    _pieTextureUniform         = glGetUniformLocation(_pieProgramHandle, "Texture");
    _pieLightDirectionnUniform = glGetUniformLocation(_pieProgramHandle, "LightIn");

    GLuint shaodwVertexShader   = [self compileShader:@"ShadowVertex" withType:GL_VERTEX_SHADER];
    GLuint shadowFragmentShader = [self compileShader:@"ShadowFragment" withType:GL_FRAGMENT_SHADER];
    
    
    _shadowProgramHandle = glCreateProgram();
    glAttachShader(_shadowProgramHandle, shaodwVertexShader);
    glAttachShader(_shadowProgramHandle, shadowFragmentShader);
    glLinkProgram(_shadowProgramHandle);
    
    glGetProgramiv(_shadowProgramHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_shadowProgramHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    _shadowPositionSlot   = glGetAttribLocation(_shadowProgramHandle, "Position");
    _shadowColorSlot      = glGetAttribLocation(_shadowProgramHandle, "SourceColor");
    _shadowTexCoordSlot   = glGetAttribLocation(_shadowProgramHandle, "TexCoordIn");
    _shadowNormalSlot     = glGetAttribLocation(_shadowProgramHandle, "NormalIn");
    
    glEnableVertexAttribArray(_shadowPositionSlot);
    glEnableVertexAttribArray(_shadowColorSlot);
    glEnableVertexAttribArray(_shadowTexCoordSlot);
    glEnableVertexAttribArray(_shadowNormalSlot);
    
    _shadowProjectionUniform      = glGetUniformLocation(_shadowProgramHandle, "Projection");
    _shadowTextureUniform         = glGetUniformLocation(_shadowProgramHandle, "Texture");
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView: self.superview];
    
    if (CGRectContainsPoint(self.frame, touchLocation)) {
        
        _isDragging = YES;
        _oldTouchX = touchLocation.x;
        _oldTouchY = touchLocation.y;
    }
}




- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (_isDragging) {
        
        float deltax = (touchLocation.x - _oldTouchX)/90.0;
        float deltay = (touchLocation.y - _oldTouchY)/360.0;
        _rotatePieX += deltay*100;
        _rotatePieY += deltax*100;
        if(_rotatePieX<30){
            _rotatePieX = 30;
        }else if(_rotatePieX>90){
            _rotatePieX = 90;
        }
    }
    
    _oldTouchX = touchLocation.x;
    _oldTouchY = touchLocation.y;
}




- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _isDragging = NO;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




- (void)dealloc{
    [self destroyTimer];
    
    // tear down context
	if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
	
	[_context release];
	_context = nil;
    
    [super dealloc];
}

@end
