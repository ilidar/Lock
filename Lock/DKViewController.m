//
//  DKViewController.m
//  Lock
//
//  Created by Denys Kotelovych on 20.11.13.
//  Copyright (c) 2013 D.K. All rights reserved.
//

#import "DKViewController.h"

static const CGFloat sDotRadius = 8.0f;
static const CGFloat sDotMargin = 4.0f;
static const CGFloat sSurfaceRadius = 150.0f;
static const CGFloat sTouchCircleRadius = 40.0f;

static inline CGFloat sGetSurfaceRadiusChange()
{
  return sDotMargin + sDotRadius;
}

static inline CGFloat sGetArcChange(CGFloat radius)
{
  CGFloat da = asin((sDotRadius + sDotMargin) / radius) * 180.0f / M_PI;
  
  int n = 360.0f / da;
  
  CGFloat ds = 360.0f - ( da * n );
  
  CGFloat dda = ds / n;
  
  da += dda;
  
  return da;
}

static inline CGPoint sGetDotCenter(CGFloat angle, CGPoint beginPoint, CGPoint center)
{
  CGAffineTransform transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0f);
  
  CGPoint dotCenter = CGPointApplyAffineTransform(beginPoint, transform);
  
  dotCenter.x += center.x;
  dotCenter.y += center.y;
  
  return dotCenter;
}

@interface LockView : UIView

@property (nonatomic, assign) CGPoint currentPosition;

@end

@implementation LockView

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.currentPosition = [[touches anyObject] locationInView:self];
  
  [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  self.currentPosition = [[touches anyObject] locationInView:self];
  
  [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  self.currentPosition = CGPointZero;
  
  [self setNeedsDisplay];
}

#pragma mark - Draw Methods

- (void)drawRect:(CGRect)rect {
  CGFloat surfaceRadiusChange = sGetSurfaceRadiusChange();
  
  for (CGFloat r = 2.0f * surfaceRadiusChange; r <= sSurfaceRadius; r += surfaceRadiusChange) {
    CGPoint beginPoint = CGPointMake(r, 0.0f);
    
    CGFloat angleChange = sGetArcChange(r);
    
    for (CGFloat alpha = 0.0f; alpha <= 360.0f; alpha += angleChange) {
      [self pm_drawCircleAtPoint:sGetDotCenter(alpha, beginPoint, self.center)];
    }
  }
}

#pragma mark - Private Methods

- (void)pm_drawCircleAtPoint:(CGPoint)point color:(UIColor *)color {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(context, 2.0);
  
  CGContextSetFillColorWithColor(context, color.CGColor);
  
  CGRect rectangle = CGRectMake(point.x - sDotRadius / 2.0f,
                                point.y - sDotRadius / 2.0f,
                                sDotRadius,
                                sDotRadius);
  
  CGContextAddEllipseInRect(context, rectangle);
  
  CGContextFillPath(context);
}

- (void)pm_drawCircleAtPoint:(CGPoint)point {
  [self pm_drawCircleAtPoint:point color:[UIColor blueColor]];
}

@end

@implementation DKViewController

- (void)loadView
{
  self.view = [[LockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.view.backgroundColor = [UIColor whiteColor];
}

@end
