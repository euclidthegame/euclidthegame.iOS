//
//  DHLevelCircleCenter.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2014 David Hallgren. All rights reserved.
//

#import "DHLevelCircleCenter.h"

#import "DHGeometricObjects.h"

@interface DHLevelCircleCenter () {
    DHPoint* _pointC;
    DHPoint* _pointR;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

@end

@implementation DHLevelCircleCenter

- (NSString*)subTitle
{
    return @"Circle center";
}

- (NSString*)levelDescription
{
    return (@"Construct a point at the center of the given circle.");
}

- (NSUInteger)minimumNumberOfMoves
{
    return 3;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 5;
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:200 andY:200];
    DHPoint* pB = [[DHPoint alloc] initWithPositionX:300 andY:200];
    
    DHCircle* circle = [[DHCircle alloc] init];
    circle.center = pA;
    circle.pointOnRadius = pB;
    
    [geometricObjects addObject:circle];
    
    _pointC = pA;
    _pointR = pB;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    [objects addObject:_pointC];
}

- (BOOL)isLevelComplete:(NSMutableArray*)geometricObjects
{
    BOOL complete = [self isLevelCompleteHelper:geometricObjects];
    if (!complete) {
        return NO;
    }
    
    // Move A and B and ensure solution holds
    CGPoint pointA = _pointC.position;
    CGPoint pointB = _pointR.position;
    
    _pointC.position = CGPointMake(pointA.x - 1, pointA.y - 1);
    _pointR.position = CGPointMake(pointB.x + 1, pointB.y + 1);
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    complete = [self isLevelCompleteHelper:geometricObjects];
    _pointC.position = pointA;
    _pointR.position = pointB;
    for (id object in geometricObjects) {
        if ([object respondsToSelector:@selector(updatePosition)]) {
            [object updatePosition];
        }
    }
    
    return complete;
}

- (BOOL)isLevelCompleteHelper:(NSMutableArray*)geometricObjects
{
    for (id object in geometricObjects){
        if(EqualPoints(object, _pointC)) {
            self.progress = 100;
            return YES;
        }
    }
    
    return NO;
}
- (CGPoint)testObjectsForProgressHints:(NSArray *)objects{
    
    for (id object in objects){
        
        if(EqualPoints(object, _pointC)) return _pointC.position;
    }
    
    
    return CGPointMake(NAN, NAN);
}

- (void)hint:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view and:(NSLayoutConstraint*)heightToolBar and:(UIButton*)hintButton{
    
    if ([self.hintButton.titleLabel.text isEqualToString:@"Hide hint"] ) {
        [self hideHint];
        return;
    }
    
    if (hint2_OK) {
        [self showTemporaryMessage:@"No more hints available." atPoint:CGPointMake(self.geometryView.center.x,50) withColor:[UIColor darkGrayColor] andTime:3.0];
        [hintButton setTitle:@"Show hint" forState:UIControlStateNormal];
        hint1_OK = NO;
        hint2_OK = NO;
        return;
    }
    
    [hintButton setTitle:@"Hide hint" forState:UIControlStateNormal];
    for (int a=0; a<90; a++) {
        [self performBlock:^{
            heightToolBar.constant= 70 - a;
        } afterDelay:a* (1/90.0) ];
    }
    
    Message* message1 = [[Message alloc] initWithMessage:@"For a moment, suppose that we do know the center of the circle." andPoint:CGPointMake(200,320)];
    Message* message2 = [[Message alloc] initWithMessage:@"And let's draw a line segment connecting two points on the circle." andPoint:CGPointMake(200,340)];
    Message* message3 = [[Message alloc] initWithMessage:@"We can drop a perpendicular from the center to the line segment." andPoint:CGPointMake(200,360)];
    Message* message4 = [[Message alloc] initWithMessage:@"How can we construct such a point ?" andPoint:CGPointMake(200,380)];
    Message* message5 = [[Message alloc] initWithMessage:@"How can we construct such a point ?" andPoint:CGPointMake(200,400)];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        [message1 position: CGPointMake(150,500)];
        [message2 position: CGPointMake(150,520)];
        [message3 position: CGPointMake(150,540)];
        [message4 position: CGPointMake(150,560)];
    }
    
    
    _pointC.label = @"A";
    DHGeometryView* centerView = [[DHGeometryView alloc]initWithObjects:@[_pointC] andSuperView:geometryView];
    DHCircle* circle = [[DHCircle alloc] initWithCenter:_pointC andPointOnRadius:_pointR];
    DHPointOnCircle* p1 = [[DHPointOnCircle alloc]initWithCircle:circle andAngle:1.5];
    p1.label = @"B";
    DHPointOnCircle* p2 = [[DHPointOnCircle alloc]initWithCircle:circle andAngle:3.0];
    p2.label = @"C";
    DHLineSegment* segment = [[DHLineSegment alloc]initWithStart:p1 andEnd:p2];
    
    DHPerpendicularLine* perp = [[DHPerpendicularLine alloc]initWithLine:segment andPoint:_pointC];
    DHMidPoint* intersection = [[DHMidPoint alloc]initWithPoint1:p1 andPoint2:p2];
    intersection.label = @"D";
    
    DHGeometryView* segmentView = [[DHGeometryView alloc]initWithObjects:@[segment,p1,p2] andSuperView:geometryView];
    
    DHGeometryView* perpView = [[DHGeometryView alloc]initWithObjects:@[perp,intersection] andSuperView:geometryView];
    
    DHLineSegment* segment2 = [[DHLineSegment alloc]initWithStart:p1 andEnd:_pointC];
    DHLineSegment* segment3 = [[DHLineSegment alloc]initWithStart:p2 andEnd:_pointC];
    DHGeometryView* segmentsView  = [[DHGeometryView alloc] initWithObjects:@[segment2,segment3] andSuperView:geometryView];
    
    UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];
    [geometryView addSubview:hintView];
    
    
    
    [hintView addSubview:segmentsView];
    [hintView addSubview:segmentView];
    [hintView addSubview:perpView];
    [hintView addSubview:centerView];
    [hintView addSubview:message1];
    [hintView addSubview:message2];
    [hintView addSubview:message3];
    [hintView addSubview:message4];
    
    [hintView addSubview:message5];
    
    if (!hint1_OK) {
        [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            message1.alpha = 1; } completion:^(BOOL finished){ }];
        [self fadeIn:centerView withDuration:2];
        
        [self afterDelay:4.0 performBlock:^{
            [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                message2.alpha = 1; } completion:^(BOOL finished){ }];
            [self fadeIn:segmentView withDuration:2];
        }];
        
        [self afterDelay:8.0 performBlock:^{
            [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                message3.alpha = 1; } completion:^(BOOL finished){ }];
            [self fadeIn:perpView withDuration:2];
        }];
        
        [self afterDelay:12.0 performBlock:^{
            [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                message1.alpha = 0;
                message2.alpha =0 ;
                message3.alpha = 0;
            } completion:nil];
        }];
        
        [self afterDelay:14.0 performBlock:^{
            [message1 text:@"It looks like D is the midpoint of line segment BC."];
            [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
                message1.alpha = 1;
            }completion:^(BOOL finished){ }];
            
        }];
        [self afterDelay:18.0 performBlock:^{
            [message2 text:@"This follows from the Pythagoras Theorem."];
            [self fadeIn:segmentsView withDuration:2];
            [self fadeIn:message2 withDuration:1];
        }];
        
        [self afterDelay:22.0 performBlock:^{
            [message3 text:@"AD² + CD² = AC² and AD²+ BD² = AB²"];
            [self fadeIn:message3 withDuration:1];
        }];
        
        [self afterDelay:26.0 performBlock:^{
            [message4 text:@"          CD² = AC² and          BD² = AB²"];
            [self fadeIn:message4 withDuration:1];
        }];
        [self afterDelay:30.0 performBlock:^{
            [message5 text:@"As AC = AB, it follows that CD must be equal to BD."];
            [self fadeIn:message5 withDuration:1];
            hint1_OK = YES;
        }];
    }
    else if (!hint2_OK){
        segment.temporary = YES;
        perp.temporary = YES;
        
        [self afterDelay:0.0 performBlock:^{
            [message1 text:@"Hence, if we draw a line segment connecting the two points on the circle."];
            [self fadeIn:message1 withDuration:1];
            [self fadeIn:segmentView withDuration:2];
        }];
        [self afterDelay:4.0 performBlock:^{
            [message2 text:@"We can draw a perpendicular from the midpoint."];
            [self fadeIn:perpView withDuration:2];
            [self fadeIn:message2 withDuration:1];
        }];
        [self afterDelay:8.0 performBlock:^{
            [message3 text:@"And we know that this line passes through the center of the circle."];
            [self fadeIn:message3 withDuration:1];
            hint2_OK = YES;
            [segmentView.geometricObjects addObjectsFromArray:@[perp,intersection]];
            [segmentView setNeedsDisplay];
            [self fadeOut:perpView withDuration:0];
        }];
        
        [self afterDelay:12.0 performBlock:^{
            [message4 text:@"For any points B and C on the circle."];
            [self fadeIn:message4 withDuration:1];
            [self movePointOnCircle:p1 toAngle:1.5+2*M_PI withDuration:4 inView:segmentView];
            hint2_OK = YES;
        }];
        [self afterDelay:16.0 performBlock:^{
            [self movePointOnCircle:p2 toAngle:3.0-2*M_PI withDuration:4 inView:segmentView];
            hint2_OK = YES;
        }];
        
        
        
    }
    
}

-(void)animation:(NSMutableArray *)geometricObjects and:(UISegmentedControl *)toolControl and:(UILabel *)toolInstructions and:(DHGeometryView *)geometryView and:(UIView *)view {
    
    
    CGFloat steps = 100;
    CGPoint oldOffset = geometryView.geoViewTransform.offset;
    CGFloat oldScale = geometryView.geoViewTransform.scale;
    CGFloat newScale = 1;
    CGPoint newOffset = CGPointMake(0,0);
    
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
        [geometryView.geoViewTransform setScale:newScale];
        [geometryView centerContent];
        newOffset = geometryView.geoViewTransform.offset;
        [geometryView.geoViewTransform setOffset:oldOffset];
        [geometryView.geoViewTransform setScale:oldScale];

    }
    
    CGPoint offset = PointFromToWithSteps(oldOffset, newOffset, 100);
    CGFloat scale =  pow((newScale/oldScale),0.01) ;
    
    
    for (int a=0; a<steps; a++) {
        [self performBlock:^{
            [geometryView.geoViewTransform offsetWithVector:CGPointMake(offset.x, offset.y)];
            [geometryView.geoViewTransform setScale:geometryView.geoViewTransform.scale *scale];
            [geometryView setNeedsDisplay];
        } afterDelay:a* (1/steps)];
    }

    [self afterDelay:1.0 performBlock:^{
        DHCircle* circle = [[DHCircle alloc]initWithCenter:_pointC andPointOnRadius:_pointR];
        DHGeometryView* animationView = [[DHGeometryView alloc]initWithObjects:@[_pointC,circle] andSuperView:view andGeometryView:geometryView];
        
        [view addSubview:animationView];
        
        UIView* segment1= [toolControl.subviews objectAtIndex:4];
        UIView* segment2 = [toolControl.subviews objectAtIndex:5];
        CGPoint pos1 = [segment1.superview convertPoint:segment1.frame.origin toView:animationView];
        CGPoint pos2 = [segment2.superview convertPoint:segment2.frame.origin toView:animationView];
        pos1 = CGPointMake(pos1.x -newOffset.x, pos1.y - newOffset.y);
        pos2 = CGPointMake(pos2.x - newOffset.x, pos2.y - newOffset.y);
        CGFloat xpos = (pos1.x + pos2.x )/2 ;
        CGFloat ypos =  pos2.y;
        CGFloat radius = pos1.x -15;
        
        if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
            radius = radius - 10;
        }
        
        DHPoint* endpointC = [[DHPoint alloc]initWithPositionX:xpos andY:ypos-30];
        DHPoint* endpointR = [[DHPoint alloc]initWithPositionX:radius andY:ypos-30];

         [self movePointFrom:_pointC to:endpointC withDuration:4.0 inView:animationView];
         [self movePointFrom:_pointR to:endpointR withDuration:4.0 inView:animationView];
         UIView* toolSegment = [toolControl.subviews objectAtIndex:11-6];
         UIImageView* tool = [toolSegment.subviews objectAtIndex:0];
         
         [self afterDelay:3.0 performBlock:^{
         [self fadeOut:tool withDuration:1.0];
             [self fadeOut:animationView withDuration:1.5];
         }];
         [self afterDelay:4.0 performBlock:^{
             
             tool.image = [UIImage imageNamed:@"toolMidpointImproved"];
         [self fadeIn:tool withDuration:1.0];

         }];
        [self afterDelay:5.0 performBlock:^{
            [animationView removeFromSuperview];
        }];
  
        
    }];
    

}
-(void)hideHint {
    for (int a=0; a<90; a++) {
        [self performBlock:^{
            self.heightToolbar.constant= -20 + a;
        } afterDelay:a* (1/90.0) ];
    }
    if (!hint1_OK){        [self.hintButton setTitle:@"Show hint" forState:UIControlStateNormal];}
    else {[self.hintButton setTitle:@"Show next hint" forState:UIControlStateNormal];}
    [self.geometryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    return;
}
@end
