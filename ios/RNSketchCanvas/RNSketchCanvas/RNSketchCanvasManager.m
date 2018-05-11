#import "RNSketchCanvasManager.h"
#import "RNSketchCanvas.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTView.h>
#import <React/UIView+React.h>

@implementation RNSketchCanvasManager

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

#pragma mark - Events

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock);

#pragma mark - Props
RCT_CUSTOM_VIEW_PROPERTY(localSourceImagePath, NSString, RNSketchCanvas)
{
    RNSketchCanvas *currentView = !view ? defaultView : view;
    NSString *localFilePath = [RCTConvert NSString:json];
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentView openSketchFile:localFilePath];
    });
}
    
#pragma mark - Lifecycle

- (instancetype)init
{
    if ((self = [super init])) {
        self.sketchCanvasView = nil;
    }

    return self;
}

- (UIView *)view
{
    if (!self.sketchCanvasView) {
        self.sketchCanvasView = [[RNSketchCanvas alloc] initWithEventDispatcher: self.bridge.eventDispatcher];
        
//        NSString * path1 = @"/Users/diegocaceres/Library/Developer/CoreSimulator/Devices/B3AF1207-928D-4653-A66A-45D23246E0F1/data/Containers/Data/Application/966FDCD3-BBE0-462F-85AC-EDCF7D11D52B/Library/Caches/Camera/41374802-C140-4869-9EDE-38E6E47E0795.jpg";
//        NSString * path2 = @"file:///Users/diegocaceres/Library/Developer/CoreSimulator/Devices/B3AF1207-928D-4653-A66A-45D23246E0F1/data/Containers/Data/Application/966FDCD3-BBE0-462F-85AC-EDCF7D11D52B/Library/Caches/Camera/41374802-C140-4869-9EDE-38E6E47E0795.jpg";
//        UIImage *image1 = [UIImage imageWithContentsOfFile:path1];
//        UIImage *image2 = [UIImage imageWithContentsOfFile:path2];
        
//        NSString * MyURL = @"https://i.pinimg.com/736x/8f/a9/11/8fa911b42d3de9b5cb949507c80dc928--senior-pics-water-cute-senior-pictures-poses.jpg";

//        UIImage *image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:MyURL]]];
        
//        if(image1) {
//            [self.sketchCanvasView setViewImage:image1];
//        }
        
//        // /Users/diegocaceres/Library/Developer/CoreSimulator/Devices/B3AF1207…2240A847178/Library/Caches/Camera/6959E903-D9C1-415C-97B4-93E2D1389052.jpg
//        NSString * path = @"assets-library://asset/asset.JPG?id=0866602D-6A30-44AD-9569-F075F818321B&ext=JPG";
//        UIImage *image = [UIImage imageWithContentsOfFile:path];
//        NSString * path2 = @"/asset/asset.JPG?id=0866602D-6A30-44AD-9569-F075F818321B&ext=JPG";
//        UIImage *image2 = [UIImage imageWithContentsOfFile:path2];
//        NSString * path3 = @"/assets-library://asset/asset.JPG?id=0866602D-6A30-44AD-9569-F075F818321B&ext=JPG";
//        UIImage *image3 = [UIImage imageWithContentsOfFile:path3];
//        if(image) {
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//            [imageView setImage:image];
//            [self.sketchCanvasView addSubview:imageView]; // edited for syntax
//        }
    }

    return self.sketchCanvasView;
}

#pragma mark - Exported methods


RCT_EXPORT_METHOD(save:(NSString*) type withTransparentBackground:(BOOL) transparent path:(NSString*) localFilePath)
{
//    NSString * path = @"/Users/diegocaceres/Library/Developer/CoreSimulator/Devices/B3AF1207-928D-4653-A66A-45D23246E0F1/data/Containers/Data/Application/773ACF2D-B10F-47F4-B00B-6C572F1D6CEA/Library/Caches/Camera/B6B8FADA-3917-4951-A8B9-87938FA1C247.jpg";
//    UIImage *image = [UIImage imageWithContentsOfFile:localFilePath];
//    if(image) {
//        [self.sketchCanvasView setViewImage:image];
//    }
    
    [self.sketchCanvasView saveImageOfType: type withTransparentBackground: transparent];
}

RCT_EXPORT_METHOD(addPoint: (float)x : (float)y)
{
    [self.sketchCanvasView addPointX:x Y:y];
}

RCT_EXPORT_METHOD(addPath: (int) pathId strokeColor: (UIColor*) strokeColor strokeWidth: (int) strokeWidth points: (NSArray*) points)
{
    NSMutableArray *cgPoints = [[NSMutableArray alloc] initWithCapacity: points.count];
    for (NSString *coor in points) {
        NSArray *coorInNumber = [coor componentsSeparatedByString: @","];
        [cgPoints addObject: [NSValue valueWithCGPoint: CGPointMake([coorInNumber[0] floatValue], [coorInNumber[1] floatValue])]];
    }
    [self.sketchCanvasView addPath: pathId strokeColor: strokeColor strokeWidth: strokeWidth points: cgPoints];
}

RCT_EXPORT_METHOD(newPath: (int) pathId strokeColor: (UIColor*) strokeColor strokeWidth: (int) strokeWidth)
{
    [self.sketchCanvasView newPath: pathId strokeColor: strokeColor strokeWidth: strokeWidth];
}

RCT_EXPORT_METHOD(deletePath: (int) pathId)
{
    [self.sketchCanvasView deletePath: pathId];
}

RCT_EXPORT_METHOD(endPath)
{
    [self.sketchCanvasView endPath];
}

RCT_EXPORT_METHOD(clear)
{
    [self.sketchCanvasView clear];
}

RCT_EXPORT_METHOD(transferToBase64: (NSString*) type withTransparentBackground:(BOOL) transparent :(RCTResponseSenderBlock)callback)
{
    callback(@[[NSNull null], [self.sketchCanvasView transferToBase64OfType: type withTransparentBackground: transparent]]);
}

@end
