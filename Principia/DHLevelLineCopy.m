//
//  DHLevelLineCopy.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-05.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelLineCopy.h"

#import "DHGeometricObjects.h"

@interface DHLevelLineCopy () {
    DHLineSegment* _lineAB;
    DHPoint* _pointA;
    DHPoint* _pointB;
    DHPoint* _pointC;
}

@end

@implementation DHLevelLineCopy

- (NSString*)subTitle
{
    return @"Copy the line";
}

- (NSString*)levelDescription
{
    return @"Translate the segment AB to the point C.";
}

- (NSString*)levelDescriptionExtra
{
    return @"Translate the segment AB to point C. \n\nIn other words, construct a line segment with the same length and same direction as line segment AB but with starting point C.";
}

- (NSString *)additionalCompletionMessage
{
    return (@"You unlocked a new tool: Translating lines! Note that this new tool won't work when all points "
            @"lay on the same line. Enhance your new tool in Level 8.");
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 6;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:230 andY:100];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:350 andY:450];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    
    [geometricObjects addObject:l1];
    [geometricObjects addObject:p1];
    [geometricObjects addObject:p2];
    [geometricObjects addObject:p3];
    _pointA = p1;
    _pointB = p2;
    _pointC = p3;
    _lineAB = l1;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = _pointC;
    p.translationStart = _lineAB.start;
    p.translationEnd = _lineAB.end;
    
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:_pointC andEnd:p];
    
    [objects insertObject:l atIndex:0];
    [objects addObject:p];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _lineAB.start.position;
    CGPoint pointB = _lineAB.end.position;
    
    _lineAB.start.position = CGPointMake(pointA.x+1, pointA.y+2);
    _lineAB.end.position = CGPointMake(pointB.x-3, pointB.y-4);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    
    _lineAB.start.position = pointA;
    _lineAB.end.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    BOOL parallelLineOK = NO;
    BOOL intersectingLineOK = NO;
    
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    
    // First, look for a point translated from C at distance AB and parallell to AB
    for (int index = 0; index < geometricObjects.count; ++index) {
        id object = [geometricObjects objectAtIndex:index];
        
        if ([[object class]  isSubclassOfClass:[DHLineObject class]]) {
            DHLineObject* l = object;
            BOOL intersectsTP = PointOnLine(tp, l);
            if (PointOnLine(_pointC, l) && intersectsTP) {
                parallelLineOK = YES;
            } else if (intersectsTP) {
                intersectingLineOK = YES;
            }
        }
        
        if ([[object class]  isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            if (parallelLineOK && EqualPoints(p, tp)) {
                self.progress = 100;
                return YES;
            }
        }
    }
    
    self.progress = (parallelLineOK + intersectingLineOK)/3.0*100;
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{
    DHParallelLine* par1 = [[DHParallelLine alloc] initWithLine:_lineAB andPoint:_pointC];
    DHLine* lineAC = [[DHLine alloc] initWithStart:_lineAB.start andEnd:_pointC];
    DHParallelLine* par2 = [[DHParallelLine alloc] initWithLine:lineAC andPoint:_lineAB.end];
    DHTranslatedPoint* tp = [[DHTranslatedPoint alloc] init];
    tp.startOfTranslation = _pointC;
    tp.translationStart = _lineAB.start;
    tp.translationEnd = _lineAB.end;
    
    for (id object in objects){
        if (EqualDirection(object,par1))  return MidPointFromLine(par1);
        if (EqualDirection(object,lineAC)) return MidPointFromLine(lineAC);
        if (EqualDirection(object,par2))  return MidPointFromLine(par2);
        if (EqualPoints(object,tp)) return tp.position;
    }
    return CGPointMake(NAN, NAN);
}
- (void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    
    NSMutableArray* geometricObjects2 = [[NSMutableArray alloc]init];
    DHPoint* p1 = [[DHPoint alloc] initWithPositionX:180 andY:400];
    DHPoint* p2 = [[DHPoint alloc] initWithPositionX:230 andY:100];
    DHPoint* p3 = [[DHPoint alloc] initWithPositionX:350 andY:450];
    
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:p1 andEnd:p2];
    
    [geometricObjects2 addObject:l1];
    [geometricObjects2 addObject:p1];
    [geometricObjects2 addObject:p2];
    [geometricObjects2 addObject:p3];
    

    DHTranslatedPoint* p = [[DHTranslatedPoint alloc] init];
    p.startOfTranslation = p3;
    p.translationStart = l1.start;
    p.translationEnd = l1.end;
    
    DHLineSegment* l = [[DHLineSegment alloc] initWithStart:p3 andEnd:p];
    
    [geometricObjects2 insertObject:l atIndex:0];
    [geometricObjects2 addObject:p];
    
    CGFloat steps = 100;
    CGPoint dA = PointFromToWithSteps(_pointA.position, p1.position, steps);
    CGPoint dB = PointFromToWithSteps(_pointB.position, p2.position, steps);
    CGPoint dC = PointFromToWithSteps(_pointC.position, p3.position, steps);
    
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [geometryView.geoViewTransform setScale:newScale];
        CGPoint oldPointA = _pointA.position;
        _pointA.position = p1.position;
        CGPoint oldPointB = _pointB.position;
        _pointB.position = p2.position;
        CGPoint oldPointC = _pointC.position;
        _pointC.position = p3.position;
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];
        _pointA.position = oldPointA;
        _pointB.position = oldPointB;
        _pointC.position = oldPointC;
    }
    
    
    CGPoint offset = PointFromToWithSteps(oldOffset, newOffset, 100);
    CGFloat scale =  pow((newScale/oldScale),0.01) ;
    
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(offset.x, offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            _pointA.position = CGPointMake(_pointA.position.x + dA.x,_pointA.position.y + dA.y);
            _pointB.position = CGPointMake(_pointB.position.x + dB.x,_pointB.position.y + dB.y);
            _pointC.position = CGPointMake(_pointC.position.x + dC.x,_pointC.position.y + dC.y);
            for (id object in geometryView.geometricObjects) {
                if ([object respondsToSelector:@selector(updatePosition)]) {
                    [object updatePosition];
                }
            }
            [geometryView setNeedsDisplay];
        } afterDelay:a* (1/steps)];
    }
    
    
    [self performBlock:^{
        DHGeometryView* geoView = [[DHGeometryView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
        [view addSubview:geoView];
        geoView.hideBorder = YES;
        geoView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        geoView.opaque = NO;
        geoView.geometricObjects = geometricObjects2;
        //adjust points to new coordinates
        
        
        CGPoint relPos = [geoView.superview convertPoint:geoView.frame.origin toView:geometryView];
        p1.position = CGPointMake(p1.position.x + newOffset.x, p1.position.y - relPos.y + newOffset.y );
        p2.position = CGPointMake(p2.position.x +newOffset.x  , p2.position.y - relPos.y +newOffset.y );
        p3.position = CGPointMake(p3.position.x +newOffset.x  , p3.position.y - relPos.y +newOffset.y );
        
        [geoView setNeedsDisplay];
        
        //getcoordinates of Equilateral triangle tool
        UIView* segment5 = [toolControl.subviews objectAtIndex:0];
        UIView* segment6 = [toolControl.subviews objectAtIndex:1];
        CGPoint pos5 = [segment5.superview convertPoint:segment5.frame.origin toView:geoView];
        CGPoint pos6 = [segment6.superview convertPoint:segment6.frame.origin toView:geoView];
        
        CGFloat xpos = (pos5.x + pos6.x )/2 -4 ;
        CGFloat ypos =  view.frame.size.height - 12;
        
        if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            ypos = ypos -15 ;
            xpos = xpos ;
        }
        
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.keyPath = @"position";
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(geoView.layer.position.x, geoView.layer.position.y)];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(xpos, ypos)];
        animation.duration = 3;
        
        CABasicAnimation *animation2 = [CABasicAnimation animation];
        animation2.keyPath = @"transform.scale";
        animation2.fromValue = [NSNumber numberWithFloat:1];
        animation2.toValue = [NSNumber numberWithFloat:0.12];
        animation2.duration = 3;
        
        CABasicAnimation *animation3 = [CABasicAnimation animation];
        animation3.keyPath = @"transform.rotation";
        animation3.fromValue = [NSNumber numberWithFloat:0];
        animation3.toValue = [NSNumber numberWithFloat:0.70];
        animation3.duration = 3;
        animation3.removedOnCompletion = NO;
        
        [geoView.layer addAnimation:animation forKey:@"basic1"];
        [geoView.layer addAnimation:animation2 forKey:@"basic2"];
        [geoView.layer addAnimation:animation3 forKey:@"basic3"];
        
        geoView.layer.position = CGPointMake(xpos, ypos);
        geoView.transform = CGAffineTransformMakeScale(0.12, 0.12);
        [geoView.layer setValue:[NSNumber numberWithFloat:0.70] forKeyPath:@"transform.rotation"];
        
        
        [self performBlock:^{
            
            CABasicAnimation *animation4 = [CABasicAnimation animation];
            animation4.keyPath = @"opacity";
            animation4.fromValue = [NSNumber numberWithFloat:1];
            animation4.toValue = [NSNumber numberWithFloat:0];
            animation4.duration = 1;
            [geoView.layer addAnimation:animation4 forKey:@"basic4"];
            geoView.alpha = 0;
            
            
        } afterDelay:2.8];
        [UIView
         animateWithDuration:1.0 delay:3 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
             [toolControl setEnabled:YES forSegmentAtIndex:10];
         }
         completion:^(BOOL finished){
             [geoView removeFromSuperview];
         }];
    } afterDelay:1.0];
}
@end
