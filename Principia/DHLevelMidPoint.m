//
//  DHLevel3.m
//  Euclid
//
//  Created by David Hallgren on 2014-06-25.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelMidPoint.h"
#import <CoreGraphics/CGBase.h>
#import "DHGeometricObjects.h"

@interface DHLevelMidPoint () {
    DHLineSegment* _initialLine;
}

@end

@implementation DHLevelMidPoint

- (NSString*)subTitle
{
    return @"Half 'n Half";
}

- (NSString*)levelDescription
{
    return @"Construct the midpoint of line segment AB.";
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct the midpoint of line segment AB. \n\nThe midpoint divides the line segment AB into two parts of equal length.");
}

- (NSString *)additionalCompletionMessage
{
    return @"Well done ! You unlocked a new tool: Constructing a midpoint!";
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 3;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
    DHLineSegment* l1 = [[DHLineSegment alloc] init];
    l1.start = p1;
    l1.end = p2;
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    
    _initialLine = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHMidPoint* mid = [[DHMidPoint alloc] init];
    mid.start = _initialLine.start;
    mid.end = _initialLine.end;
    [objects addObject:mid];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _initialLine.start.position;
    CGPoint pointB = _initialLine.end.position;
    
    _initialLine.start.position = CGPointMake(100, 100);
    _initialLine.end.position = CGPointMake(400, 400);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _initialLine.start.position = pointA;
    _initialLine.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL pointOnMidLineOK = NO;
    BOOL secondPontOnMidLineOK = NO;
    BOOL midPointOK = NO;
    
    DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];
    DHPerpendicularLine* midLine = [[DHPerpendicularLine alloc] initWithLine:_initialLine andPoint:mp];
    
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        if ([[object class] isSubclassOfClass:[DHPoint class]] == NO) continue;
        if (object == _initialLine.start || object == _initialLine.end) continue;
        
        DHPoint* p = object;
        CGPoint currentPoint = p.position;
        if (DistanceBetweenPoints(mp.position, currentPoint) < 0.0001) {
            midPointOK = YES;
        }
        if (DistanceFromPointToLine(p, midLine) < 0.0001) {
            if (!pointOnMidLineOK) {
                pointOnMidLineOK = YES;
            } else {
                secondPontOnMidLineOK = YES;
            }
        }
    }
    
    self.progress = (pointOnMidLineOK + secondPontOnMidLineOK + midPointOK)/3.0 * 100;
    if (midPointOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{

DHCircle* cAB = [[DHCircle alloc] initWithCenter:_initialLine.start andPointOnRadius:_initialLine.end];
DHCircle* cBA = [[DHCircle alloc] initWithCenter:_initialLine.end andPointOnRadius:_initialLine.start];
DHTrianglePoint* pTop = [[DHTrianglePoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];
DHTrianglePoint* pBottom = [[DHTrianglePoint alloc] initWithPoint1:_initialLine.end andPoint2:_initialLine.start];
DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:pBottom andEnd:pTop];
DHMidPoint* mp = [[DHMidPoint alloc] initWithPoint1:_initialLine.start andPoint2:_initialLine.end];

for (id object in objects){
    if (EqualCircles(object,cAB)) return cAB.center.position;
    if (EqualCircles(object,cBA)) return cBA.center.position;
    if (EqualPoints(object, pTop)) return pTop.position;
    if (EqualPoints(object,pBottom)) return pBottom.position;
    if (LineObjectCoversSegment(object,segment)) return MidPointFromPoints(segment.start.position,segment.end.position);
    if (EqualPoints(object,mp)) return mp.position;
}
    return CGPointMake(NAN, NAN);

}

- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    CGPoint offset = CGPointMake (geometryView.geoViewTransform.offset.x /100,geometryView.geoViewTransform.offset.y /100);
    CGFloat scale =  pow(geometryView.geoViewTransform.scale,-0.01) ;
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        oldOffset = geometryView.geoViewTransform.offset;
        oldScale = geometryView.geoViewTransform.scale;
        [geometryView.geoViewTransform setScale:newScale];
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];
        offset = CGPointMake ((-newOffset.x + oldOffset.x) /100, (-newOffset.y+ oldOffset.y )/100);
        scale =  pow((oldScale/newScale),-0.01) ;
    }
    
    for (int a=0; a<100; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(-offset.x, -offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            [geometryView setNeedsDisplay];
        } afterDelay:a*0.01];
    }
    
    [self performBlock:^{
        DHGeometryView* geoView = [[DHGeometryView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        [view addSubview:geoView];
        geoView.hideBorder = YES;
        geoView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        geoView.opaque = NO;
        
        DHPoint* p1 = [[DHPoint alloc] initWithPositionX:280 andY:300];
        DHPoint* p2 = [[DHPoint alloc] initWithPositionX:480 andY:300];
        DHLineSegment* l1 = [[DHLineSegment alloc] init];
        l1.start = p1;
        l1.end = p2;
        
        NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
        
        [geometricObjects2 addObject:l1];
        [geometricObjects2 addObject:p1];
        [geometricObjects2 addObject:p2];
        
        _initialLine = l1;
        DHMidPoint* mid = [[DHMidPoint alloc] init];
        mid.start = _initialLine.start;
        mid.end = _initialLine.end;
        [geometricObjects2 addObject:mid];
        
        geoView.geometricObjects = geometricObjects2;
        
        
        //adjust points to new coordinates
        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );

        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:4];
        UIView* segment6 = [toolControl.subviews objectAtIndex:5];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
   
        CGFloat xpos = (pos5.x + pos6.x )/2  ;
        CGFloat ypos =  view.frame.size.height - 18;
        
        
        if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            ypos = ypos - 16;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position";
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(geoView.layer.position.x, geoView.layer.position.y)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(xpos, ypos)];
        animation.duration = 4;
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.keyPath = @"transform.scale";
        animation2.fromValue = [NSNumber numberWithFloat:1];
        animation2.toValue = [NSNumber numberWithFloat:0.17];
        animation2.duration = 4;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        geoView.layer.position = CGPointMake(xpos, ypos);
        
        geoView.transform = CGAffineTransformMakeScale(0.17, 0.17);
        
        [self performBlock:^{
            CABasicAnimation *animation3 = [CABasicAnimation animation];
            animation3.keyPath = @"opacity";
            animation3.fromValue = [NSNumber numberWithFloat:1];
            animation3.toValue = [NSNumber numberWithFloat:0];
            animation3.duration = 1;
            [geoView.layer addAnimation:animation3 forKey:@"basic3"];
            geoView.alpha = 0;
            
        } afterDelay:3.5];
        [UIView
         animateWithDuration:1.0 delay:4 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [toolControl setEnabled:YES forSegmentAtIndex:6];
         }
         completion:^(BOOL finished){
             [geoView removeFromSuperview];
         }];
    } afterDelay:1.0];
    
}
@end
