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
  CGFloat surfaceRadiusChange = sGetSurfaceRadiusChange();
  
  for (CGFloat r = 2.0f * surfaceRadiusChange; r <= sSurfaceRadius; r += surfaceRadiusChange) {
    CGPoint beginPoint = CGPointMake(r, 0.0f);
    
    CGFloat angleChange = sGetArcChange(r);
    
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
  
  CGRect rectangle = CGRectMake(circle.center.x - sDotRadius / 2.0f,
                                circle.center.y - sDotRadius / 2.0f,
                                sDotRadius,
                                sDotRadius);
  
  CGContextAddEllipseInRect(context, rectangle);
  
  CGContextFillPath(context);
}

@end

@implementation DKViewController

- (void)loadView
{
  self.view = [[LockView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.view.backgroundColor = [UIColor whiteColor];
}

@end
