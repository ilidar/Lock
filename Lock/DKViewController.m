//
//  DKViewController.m
//  Lock
//
//  Created by Denys Kotelovych on 20.11.13.
//  Copyright (c) 2013 D.K. All rights reserved.
//

#import "DKViewController.h"

static const CGFloat sDotRadius = 2.0f;
static const CGFloat sDotMargin = 4.0f;
static const CGFloat sSurfaceRadius = 150.0f;
static const CGFloat sTouchCircleRadius = 50.0f;

typedef struct {
  CGFloat radius;
  CGPoint center;
} Circle;

static Circle sCircleZero;

static inline Circle sCircleMake(CGPoint center, CGFloat radius)
{
  Circle circle;
  circle.radius = radius;
  circle.center = center;
  return circle;
}

static inline BOOL sCircleIntersectsCircle(Circle first, Circle second)
{
  CGFloat dx = second.center.x - first.center.x;
  CGFloat dy = second.center.y - first.center.y;
  CGFloat dist = sqrt(dx * dx + dy * dy);
  
  return dist <= first.radius + second.radius;
}

static inline CGFloat sGetSurfaceRadiusChange()
{
  return sDotMargin + sDotRadius;
}

static inline CGFloat sGetSurfaceRadiusChangeBegin()
{
  return 2.0f * sGetSurfaceRadiusChange();
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

@property (nonatomic, assign) Circle touchCircle;

@end

@implementation LockView

#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint point = [[touches anyObject] locationInView:self];
  
  self.touchCircle = sCircleMake(point, sTouchCircleRadius);
  
  [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  CGPoint point = [[touches anyObject] locationInView:self];
  
  self.touchCircle = sCircleMake(point, sTouchCircleRadius);
  
  [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  self.touchCircle = sCircleZero;
  
  [self setNeedsDisplay];
}

#pragma mark - Draw Methods

- (void)drawRect:(CGRect)rect {
  for (CGFloat radius = sGetSurfaceRadiusChangeBegin(); radius <= sSurfaceRadius; radius += sGetSurfaceRadiusChange()) {
    CGPoint beginPoint = CGPointMake(radius, 0.0f);
    
    CGFloat angleChange = sGetArcChange(radius);
    
    for (CGFloat alpha = 0.0f; alpha <= 360.0f; alpha += angleChange) {
      Circle circle = sCircleMake(sGetDotCenter(alpha, beginPoint, self.center), sDotRadius);
      
      if (sCircleIntersectsCircle(self.touchCircle, circle)) {
        [self pm_drawCircle:circle color:[UIColor redColor]];
      } else {
        [self pm_drawCircle:circle color:[UIColor blueColor]];
      }
    }
  }
}

#pragma mark - Private Methods

- (void)pm_drawCircle:(Circle)circle color:(UIColor *)color {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetLineWidth(context, 2.0);
  
  CGContextSetFillColorWithColor(context, color.CGColor);
  
  CGRect rectangle = CGRectMake(circle.center.x - circle.radius / 2.0f,
                                circle.center.y - circle.radius / 2.0f,
                                circle.radius,
                                circle.radius);
  
  CGContextAddEllipseInRect(context, rectangle);
  
  CGContextFillPath(context);
}

- (void)pm_drawGradientCircle:(Circle)circle {
  CGFloat colors [] = {
    0.2, 0.2, 0.2, 1.0,
    0.0, 0.0, 0.0, 1.0
  };
  
  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
  
  CGColorSpaceRelease(baseSpace), baseSpace = NULL;
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSaveGState(context);
  
  CGContextClip(context);
  
  CGContextDrawRadialGradient(context, gradient, circle.center, 0, circle.center, circle.radius, kCGGradientDrawsAfterEndLocation);
  
  CGGradientRelease(gradient), gradient = NULL;

  CGContextRestoreGState(context);
}

@end

@implementation DKViewController

- (void)loadView
{
  self.view = [[LockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.view.backgroundColor = [UIColor whiteColor];
}

@end
