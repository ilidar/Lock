//
//  DKViewController.m
//  Lock
//
//  Created by Denys Kotelovych on 20.11.13.
//  Copyright (c) 2013 D.K. All rights reserved.
//

#import "DKViewController.h"

static const CGFloat sDotRadius = 5.0f;
static const CGFloat sDotMargin = 7.5f;
static const CGFloat sSurfaceRadius = 150.0f;
static const CGFloat sTouchCircleRadius = 70.0f;

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
  
  return dist <= first.radius + second.radius - 4.0f;
}

static inline CGFloat sGetSurfaceRadiusChange()
{
  return sDotMargin + sDotRadius;
}

static inline CGFloat sGetSurfaceRadiusChangeBegin()
{
  return 2.0f * sGetSurfaceRadiusChange();
}

static inline CGFloat sGetSurfaceRadius()
{
  return sSurfaceRadius;
}

static inline CGFloat sGetArcChangeCoef(CGFloat radius)
{
  CGFloat da = asin((sDotRadius + sDotMargin) / radius) * 180.0f / M_PI;
  
  int n = 360.0f / da;
  
  CGFloat ds = 360.0f - ( da * n );
  
  CGFloat dda = ds / n;
  
  da += dda;
  
  return da;
}

static inline CGFloat sGetDotRadiusChangeCoef()
{
  return 0.05f;
}

static inline CGPoint sGetCircleCenter(CGFloat angle, CGPoint arcPoint, CGPoint center)
{
  CGAffineTransform transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0f);
  
  CGPoint dotCenter = CGPointApplyAffineTransform(arcPoint, transform);
  
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
  CGFloat colors [] = {
    1.0, 1.0, 1.0, 0.3,
    0.0, 0.0, 0.0, 0.7
  };
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
  
  CGFloat glossLocations[] = {0.05, 0.9};
  
  CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, glossLocations, 2);
  
  CGContextSaveGState(context);
  
  CGContextSetLineWidth(context, 2.0);
  
  CGFloat radius = sGetSurfaceRadiusChangeBegin();
  
  CGFloat dotRadiusCoef = 1.0f;
  
  while (radius <= sGetSurfaceRadius()) {
    CGPoint arcPoint = CGPointMake(radius, 0.0f);
    
    CGFloat angleChange = sGetArcChangeCoef(radius);
    
    for (CGFloat alpha = 0.0f; alpha <= 360.0f; alpha += angleChange) {
      CGPoint circleCenter = sGetCircleCenter(alpha, arcPoint, self.center);
      
      Circle circle = sCircleMake(circleCenter, sDotRadius / dotRadiusCoef);
      
      if (sCircleIntersectsCircle(self.touchCircle, circle)) {
        CGRect rectangle = CGRectMake(circle.center.x - circle.radius / 2.0f,
                                      circle.center.y - circle.radius / 2.0f,
                                      circle.radius,
                                      circle.radius);
        
        CGContextAddEllipseInRect(context, rectangle);
      }
    }
    
    dotRadiusCoef += sGetDotRadiusChangeCoef();
    
    radius += sGetSurfaceRadiusChange();
  }
  
  CGContextClip(context);
  
  CGContextDrawRadialGradient(context,
                              gradient,
                              self.touchCircle.center,
                              0,
                              self.touchCircle.center,
                              self.touchCircle.radius,
                              kCGGradientDrawsBeforeStartLocation);
  
  CGGradientRelease(gradient);
  
  CGContextRestoreGState(context);
}

@end

@implementation DKViewController

- (void)loadView
{
  self.view = [[LockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.view.backgroundColor = [UIColor blackColor];
}

@end
