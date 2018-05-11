#import "RNSketchCanvasManager.h"
#import "RNSketchCanvas.h"
#import "RNSketchData.h"
#import "RNSketchCanvasDelegate.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTView.h>
#import <React/UIView+React.h>

@implementation RNSketchCanvas
{
    RCTEventDispatcher *_eventDispatcher;
    NSMutableArray *_paths;
    RNSketchData *_currentPath;
    NSArray *_currentPoints;
    
    CAShapeLayer* _layer;
    RNSketchCanvasDelegate *delegate;
    
    //d
    UIImage *incrementalImage;
}
    
//d
-(BOOL)openSketchFile:(NSString *)localFilePath
{
    UIImage *image = [UIImage imageWithContentsOfFile:localFilePath];
    if(image) {
        incrementalImage = image;
        //[self.sketchView setViewImage:image];
        //[self.sketchView setViewImagePath: localFilePath];
        return YES;
    }
    return NO;
}

//d
-(void)setViewImage:(UIImage *)image
{
    incrementalImage = image;
}

- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
    self = [super init];
    if (self) {
        _eventDispatcher = eventDispatcher;
        _paths = [NSMutableArray new];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (!_layer) {
        CGRect bounds = self.bounds;
        
        delegate = [RNSketchCanvasDelegate new];
        _layer = [CAShapeLayer layer];
        _layer.frame = bounds;
        _layer.delegate = delegate;
        _layer.contentsScale = [UIScreen mainScreen].scale;

        [self.layer addSublayer: _layer];
    }
}

- (void)newPath:(int) pathId strokeColor:(UIColor*) strokeColor strokeWidth:(int) strokeWidth {
    if (_currentPath) {
        [_currentPath end];
    }
    _currentPath = [[RNSketchData alloc]
                    initWithId: pathId
                    strokeColor: strokeColor
                    strokeWidth: strokeWidth];
    [_paths addObject: _currentPath];
    [self invalidate: YES];
}

- (void) addPath:(int) pathId strokeColor:(UIColor*) strokeColor strokeWidth:(int) strokeWidth points:(NSArray*) points {
    bool exist = false;
    for(int i=0; i<_paths.count; i++) {
        if (((RNSketchData*)_paths[i]).pathId == pathId) {
            exist = true;
            break;
        }
    }
    
    if (!exist) {
        [_paths addObject: [[RNSketchData alloc]
                            initWithId: pathId
                            strokeColor: strokeColor
                            strokeWidth: strokeWidth
                            points: points]];
        [self invalidate: YES];
    }
}

- (void)deletePath:(int) pathId {
    int index = -1;
    for(int i=0; i<_paths.count; i++) {
        if (((RNSketchData*)_paths[i]).pathId == pathId) {
            index = i;
            break;
        }
    }
    
    if (index > -1) {
        [_paths removeObjectAtIndex: index];
        [self invalidate: YES];
    }
}

- (void)addPointX: (float)x Y: (float)y {
    _currentPoints = [_currentPath addPoint: CGPointMake(x, y)];
    [self invalidate: NO];
}

- (void)endPath {
    if (_currentPath) {
        [_currentPath end];
    }
}

- (void) clear {
    [_paths removeAllObjects];
    _currentPath = nil;
    _currentPoints = nil;
    [self invalidate: YES];
}

- (void) saveImageOfType: (NSString*) type withTransparentBackground: (BOOL) transparent {
    // This was changed so that it didn't leave a white border on the side
    //CGRect rect = self.frame;
    CGRect rect = self.bounds;
    UIImage *_originalImage = incrementalImage;
    
    //We dont use the original image size because the drawing is place wrongly if we do that.
    //UIGraphicsBeginImageContext(_originalImage.size);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef _context = UIGraphicsGetCurrentContext();
    [_originalImage drawInRect:CGRectMake(0.f, 0.f, rect.size.width, rect.size.height)];
    
    [_layer renderInContext:_context];
    
    UIImage *imgAntes = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions( _originalImage.size, NO, 0 );
    [imgAntes drawInRect:CGRectMake(0.f, 0.f, _originalImage.size.width, _originalImage.size.height)];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    //This was the original Code, but didnt draw the back image
//    UIGraphicsBeginImageContextWithOptions(rect.size, !transparent, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    if ([type isEqualToString: @"png"] && !transparent) {
//        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
//        CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
//    }
//    [_layer renderInContext:context];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    if ([type isEqualToString: @"jpg"]) {
        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else {
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData: UIImagePNGRepresentation(img)], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    //CGSize size = CGSizeMake(rect.size.width, rect.size.height);
    UIImage * scaled = [self scaleImage: incrementalImage toSize:rect.size];
    // Drawing code
    [scaled drawInRect:rect];
}

- (NSString*) transferToBase64OfType: (NSString*) type withTransparentBackground: (BOOL) transparent {
    CGRect rect = self.frame;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, !transparent, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([type isEqualToString: @"png"] && !transparent) {
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
        CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    }
    [_layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if ([type isEqualToString: @"jpg"]) {
        return [UIImageJPEGRepresentation(img, 0.9) base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
    } else {
        return [UIImagePNGRepresentation(img) base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    if (_onChange) {
        _onChange(@{ @"success": error != nil ? @NO : @YES });
    }
}

- (void) invalidate:(BOOL)shouldDispatchEvent {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_onChange && shouldDispatchEvent) {
            _onChange(@{ @"pathsUpdate": @(_paths.count) });
        }
        
        delegate.currentPoints = _currentPoints;
        delegate.paths = _paths;
        [_layer setNeedsDisplay];
    });
}

- (UIImage *)scaleImage:(UIImage *)originalImage toSize:(CGSize)size
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), originalImage.CGImage);
    } else {
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), originalImage.CGImage);
    }
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    
    return image;
}


#pragma CALayerDelegate


@end
