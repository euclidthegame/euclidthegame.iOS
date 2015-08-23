//
//  DHLevelNonEquiTri.m
//  Euclid
//
//  Created by David Hallgren on 2014-07-06.
//  Copyright (c) 2015, Kasper Peulen & David Hallgren. All rights reserved.
//  Use of this source code is governed by a MIT license that can be found in the LICENSE file.
//

#import "DHLevelNonEquiTri.h"

#import "DHGeometricObjects.h"
#import "DHLevelViewController.h"

@implementation DHLevelNonEquiTri {
    DHLineSegment* _lineAB;
    DHLineSegment* _lineCD;
    DHLineSegment* _lineEF;
    DHPoint* requiredPoint;
    BOOL hint1_OK;
    BOOL hint2_OK;
}

- (NSString*)levelDescription
{
    return (@"Construct a triangle with AB as base and sides of length CD and EF");
}

- (NSString*)levelDescriptionExtra
{
    return (@"Construct a triangle whose sides have the same length as the given segments using segment AB as base.");
}

- (DHToolsAvailable)availableTools
{
    return (DHPointToolAvailable | DHIntersectToolAvailable | DHLineSegmentToolAvailable | DHLineToolAvailable |
            DHCircleToolAvailable | DHMoveToolAvailable | DHTriangleToolAvailable | DHMidpointToolAvailable_Weak |
            DHBisectToolAvailable | DHPerpendicularToolAvailable | DHParallelToolAvailable | DHTranslateToolAvailable |
            DHCompassToolAvailable);
}

- (NSUInteger)minimumNumberOfMoves
{
    return 4;
}
- (NSUInteger)minimumNumberOfMovesPrimitiveOnly
{
    return 12;
}

- (void)createInitialObjects:(NSMutableArray *)geometricObjects
{
    hint1_OK = NO;
    hint2_OK = NO;
    
    DHPoint* pA = [[DHPoint alloc] initWithPositionX:250 andY:200];
    //DHPoint* pB = [[DHPoint alloc] initWithPositionX:400 andY:200];
    DHPoint* pC = [[DHPoint alloc] initWithPositionX:100 andY:170];
    DHPoint* pD = [[DHPoint alloc] initWithPositionX:140 andY:110];
    DHPoint* pE = [[DHPoint alloc] initWithPositionX:120 andY:230];
    DHPoint* pF = [[DHPoint alloc] initWithPositionX:180 andY:300];
    
    DHPointWithBlockConstraint* pB = [[DHPointWithBlockConstraint alloc] initWithPositionX:390 andY:200];
    
    DHLineSegment* lAB = [[DHLineSegment alloc] initWithStart:pA andEnd:pB];
    DHLineSegment* lCD = [[DHLineSegment alloc] initWithStart:pC andEnd:pD];
    DHLineSegment* lEF = [[DHLineSegment alloc] initWithStart:pE andEnd:pF];

    
    pB.updatesPositionAutomatically = YES;
    DHPointWithBlockConstraint* __weak weakpB = pB;
    [pB setConstraintBlock:^CGPoint{
        CGPoint newPBPos = weakpB.position;
        
        CGFloat distAB = DistanceBetweenPoints(pA.position, weakpB.position);
        CGFloat distCD = DistanceBetweenPoints(pC.position, pD.position);
        CGFloat distEF = DistanceBetweenPoints(pE.position, pF.position);
        CGFloat maxLength = (distCD + distEF)*0.9;
        CGFloat minLength = (MAX(distCD, distEF) - MIN(distCD, distEF))*1.1;
        
        if (distAB > maxLength) {
            CGVector vAB = CGVectorNormalize(CGVectorBetweenPoints(pA.position, weakpB.position));
            vAB = CGVectorMultiplyByScalar(vAB, maxLength);
            newPBPos = CGPointFromPointByAddingVector(pA.position, vAB);
        }
        if (distAB < minLength) {
            CGVector vAB = CGVectorNormalize(CGVectorBetweenPoints(pA.position, weakpB.position));
            vAB = CGVectorMultiplyByScalar(vAB, minLength);
            newPBPos = CGPointFromPointByAddingVector(pA.position, vAB);
        }
        
        return newPBPos;
    }];
    
    [geometricObjects addObjectsFromArray:@[lAB, lCD, lEF, pA, pB, pC, pD, pE, pF]];
    
    _lineAB = lAB;
    _lineCD = lCD;
    _lineEF = lEF;
}

- (void)createSolutionPreviewObjects:(NSMutableArray*)objects
{
    DHTranslatedPoint* tp1 = [[DHTranslatedPoint alloc] init];
    tp1.startOfTranslation = _lineAB.start;
    tp1.translationStart = _lineCD.start;
    tp1.translationEnd = _lineCD.end;

    DHTranslatedPoint* tp2 = [[DHTranslatedPoint alloc] init];
    tp2.startOfTranslation = _lineAB.end;
    tp2.translationStart = _lineEF.start;
    tp2.translationEnd = _lineEF.end;
    
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:tp1];
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:tp2];
    
    DHIntersectionPointCircleCircle* p = [[DHIntersectionPointCircleCircle alloc] init];
    p.c1 = c1;
    p.c2 = c2;
    p.onPositiveY = YES;
    
    DHLineSegment* l1 = [[DHLineSegment alloc] initWithStart:_lineAB.start andEnd:p];
    DHLineSegment* l2 = [[DHLineSegment alloc] initWithStart:_lineAB.end andEnd:p];
    
    [objects insertObject:l1 atIndex:0];
    [objects insertObject:l2 atIndex:0];
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
    
    _lineAB.start.position = CGPointMake(pointA.x + 10, pointA.y + 10);
    _lineAB.end.position = CGPointMake(pointB.x - 15, pointB.y - 15);
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
    // Solution criteria
    BOOL translatedPointFromAOK = NO;
    BOOL translatedPointFromBOK = NO;
    BOOL pointAtTriangleApexOK = NO;
    BOOL oneTriangleSideOK = NO;
    BOOL bothTriangleSidesOK = NO;
    
    CGFloat lengthCD = _lineCD.length;
    CGFloat lengthEF = _lineEF.length;
    
    for (id object in geometricObjects) {
        if ([[object class] isSubclassOfClass:[DHPoint class]]) {
            DHPoint* p = object;
            CGFloat distPA = DistanceBetweenPoints(p.position, _lineAB.start.position);
            CGFloat distPB = DistanceBetweenPoints(p.position, _lineAB.end.position);
            
            if (EqualScalarValues(lengthCD, distPA) || EqualScalarValues(lengthEF, distPA)) {
                translatedPointFromAOK = YES;
            }
            if (EqualScalarValues(lengthCD, distPB) || EqualScalarValues(lengthEF, distPB)) {
                translatedPointFromBOK = YES;
            }
            
            if ((EqualScalarValues(lengthCD, distPA) && EqualScalarValues(lengthEF, distPB)) ||
                (EqualScalarValues(lengthEF, distPA) && EqualScalarValues(lengthCD, distPB))) {
                pointAtTriangleApexOK = YES;
                
                DHLineSegment* sFromA = [[DHLineSegment alloc] initWithStart:_lineAB.start andEnd:p];
                DHLineSegment* sFromB = [[DHLineSegment alloc] initWithStart:_lineAB.end andEnd:p];
                
                BOOL segmentAOK = NO;
                BOOL segmentBOK = NO;
                
                for (id object in geometricObjects) {
                    if (LineObjectCoversSegment(object, sFromA)) segmentAOK = YES;
                    if (LineObjectCoversSegment(object, sFromB)) segmentBOK = YES;
                }
                if (segmentAOK || segmentBOK) oneTriangleSideOK = YES;
                if (segmentAOK && segmentBOK) bothTriangleSidesOK = YES;
            }
        }
    }
    
    self.progress = (translatedPointFromAOK + translatedPointFromBOK + pointAtTriangleApexOK +
                     oneTriangleSideOK + bothTriangleSidesOK)/5.0 * 100;
    
    if (pointAtTriangleApexOK && bothTriangleSidesOK) {
        self.progress = 100;
        return YES;
    }
    
    return NO;
}

- (CGPoint)testObjectsForProgressHints:(NSArray *)objects
{

    for (id object in objects){
        if ([[object class] isSubclassOfClass:[DHPoint class]]){
            requiredPoint = object;
            if ((LineSegmentsWithEqualLength([[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:requiredPoint],_lineCD) &&
                 LineSegmentsWithEqualLength([[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:requiredPoint],_lineEF) )
                ||
                (LineSegmentsWithEqualLength([[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:requiredPoint],_lineEF) &&
                 LineSegmentsWithEqualLength([[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:requiredPoint],_lineCD) ))
                return requiredPoint.position;
        }
        if (requiredPoint)
        {
            if(LineObjectCoversSegment(object, [[DHLineSegment alloc]initWithStart:_lineAB.start andEnd:requiredPoint]))
                return MidPointFromPoints(_lineAB.start.position, requiredPoint.position);
            if(LineObjectCoversSegment(object, [[DHLineSegment alloc]initWithStart:_lineAB.end andEnd:requiredPoint]))
               return MidPointFromPoints(_lineAB.end.position, requiredPoint.position);
        }
    }
    return CGPointMake(NAN, NAN);
}

- (void)showHint
{
    DHGeometryView* geometryView = self.levelViewController.geometryView;
    
    if (self.showingHint) {
        [self hideHint];
        return;
    }
    if (hint2_OK) {
        hint1_OK = NO;
        hint2_OK = NO;
    }
    self.showingHint = YES;
    
    [self slideOutToolbar];
    
    DHTranslatedPoint* tp1 = [[DHTranslatedPoint alloc] initStart:_lineCD.start end:_lineCD.end newStart:_lineAB.start];
    DHTranslatedPoint* tp2 = [[DHTranslatedPoint alloc] initStart:_lineEF.start end:_lineEF.end newStart:_lineAB.end];
    DHCircle* c1 = [[DHCircle alloc] initWithCenter:_lineAB.start andPointOnRadius:tp1];
    DHCircle* c2 = [[DHCircle alloc] initWithCenter:_lineAB.end andPointOnRadius:tp2];
    DHIntersectionPointCircleCircle* pG = [[DHIntersectionPointCircleCircle alloc] initWithCircle1:c1 andCircle2:c2 onPositiveY:YES];
    pG.label = @"G";
    
    DHPoint* pointC = [[DHPoint alloc]initWithPositionX:_lineCD.start.position.x andY:_lineCD.start.position.y];
    DHPoint* pointD = [[DHPoint alloc]initWithPositionX:_lineCD.end.position.x andY:_lineCD.end.position.y];
    DHLineSegment* tempSegment = [[DHLineSegment alloc]initWithStart:pointC andEnd:pointD];
    tempSegment.temporary = YES;
    
    DHCircle* cCD = [[DHCircle alloc] initWithCenter:pointC andPointOnRadius:pointD];
    cCD.temporary = YES;

    DHPoint* pointE = [[DHPoint alloc]initWithPositionX:_lineEF.start.position.x andY:_lineEF.start.position.y];
    DHPoint* pointF = [[DHPoint alloc]initWithPositionX:_lineEF.end.position.x andY:_lineEF.end.position.y];
    DHLineSegment* tempSegmentEF = [[DHLineSegment alloc]initWithStart:pointE andEnd:pointF];
    tempSegmentEF.temporary = YES;
    
    DHGeometryView* pointGView = [[DHGeometryView alloc] initWithObjects:@[pG] andSuperView:geometryView];
    DHGeometryView* moveCD = [[DHGeometryView alloc] initWithObjects:@[pointC,pointD,tempSegment] andSuperView:geometryView];
    DHGeometryView* moveEF = [[DHGeometryView alloc]initWithObjects:@[pointE,pointF,tempSegmentEF] andSuperView:geometryView];
    
    UIView* hintView = [[UIView alloc]initWithFrame:geometryView.frame];

    Message* message1 = [[Message alloc] initAtPoint:CGPointMake(80,460) addTo:hintView];
    if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [message1 position: CGPointMake(150,500)];
    }
    
    [geometryView addSubview:hintView];
    [hintView addSubview:moveCD];
    [hintView addSubview:moveEF];
    [hintView addSubview:pointGView];
    [hintView bringSubviewToFront:message1];
    
    //hint 1
    if (!hint1_OK){
        [message1 text:@"We are looking for a point G such that:"];
        [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            message1.alpha = 1; } completion:^(BOOL finished){ }];
        [self fadeIn:pointGView withDuration:2];
        
        [self performBlock:^{
            [message1 appendLine:@"  1. AG = CD" withDuration:2.0 forceNewLine:YES];

            [self fadeIn:moveCD withDuration:0.5];
            [self movePointFrom:pointC to:_lineAB.start withDuration:1.5 inView:moveCD];
            [self movePointFrom:pointD to:pG withDuration:1.5 inView:moveCD];
            
        } afterDelay:4.0];
        
        [self performBlock:^{
            [message1 appendLine:@"  2. BG = EF" withDuration:2.0 forceNewLine:YES];
            
            [self fadeIn:moveEF withDuration:0.5];
            [self movePointFrom:pointE to:pG withDuration:1.5 inView:moveEF];
            [self movePointFrom:pointF to:_lineAB.end withDuration:1.5 inView:moveEF];
            
        } afterDelay:8.0];
        
        [self performBlock:^{
            [message1 appendLine:@"How can we construct such a point?" withDuration:2.0 forceNewLine:YES];
            
            hint1_OK = YES;
        } afterDelay:12.0];
    }
    
    //hint 2
    else if(!hint2_OK){
        [message1 text:@"Circles have a very useful property."];
        DHCircle* cCD = [[DHCircle alloc] initWithCenter:pointC andPointOnRadius:pointD];
        cCD.temporary = YES;
        DHCircle* cEF = [[DHCircle alloc] initWithCenter:pointF andPointOnRadius:pointE];
        cEF.temporary = YES;

        DHTranslatedPoint* tpE = [[DHTranslatedPoint alloc]initStart:pointF end:pointE newStart:_lineAB.end];

        DHPointOnCircle* p1 = [[DHPointOnCircle alloc] initWithCircle:cCD andAngle: -M_PI];
        DHPointOnCircle* p2 = [[DHPointOnCircle alloc] initWithCircle:cEF andAngle: -M_PI];

        DHGeometryView* cView = [[DHGeometryView alloc] initWithObjects:@[cCD,cEF,pointC,pointF] andSuperView:geometryView];
        DHGeometryView* pView = [[DHGeometryView alloc] initWithObjects:@[p1,p2] andSuperView:geometryView];
        
        [hintView addSubview:cView];
        [hintView addSubview:pView];
        
        [UIView animateWithDuration:2 delay:0 options: UIViewAnimationOptionAllowAnimatedContent animations:^{
            message1.alpha = 1; } completion:^(BOOL finished){ }];
        [self fadeIn:cView withDuration:2];

        [self performBlock:^{
            [self fadeIn:pView withDuration:2];
            [self movePointOnCircle:p1 toAngle:M_PI + 0.33 withDuration:4 inView:pView];
            [self movePointOnCircle:p2 toAngle:M_PI + 0.25 withDuration:4 inView:pView];
            
            [message1 appendLine:@"Every point on the circle, has the same distance to the center."
                    withDuration:2.0];
            hint2_OK = YES;

        } afterDelay:4.0];
        [self afterDelay:8.0 performBlock:^{
            [message1 appendLine:@"Note that a circle can be \"moved\" using the compass tool."
                    withDuration:2.0];
            hint2_OK = YES;
        }];
        
        [self afterDelay:11.0 performBlock:^{
            [self fadeOut:pView withDuration:0.1];
            [self movePointFrom:pointC to:_lineAB.start withDuration:1.5 inView:cView];
            [self movePointFrom:pointD to:tp1 withDuration:1.5 inView:cView];
            [self movePointFrom:pointF to:_lineAB.end withDuration:1.5 inView:cView];
            [self movePointFrom:pointE to:tpE withDuration:1.5 inView:cView];
        }];
    }
    
    [self afterDelay:1.0 :^{
        hintView.frame = geometryView.frame;
    }];
    
    [self afterDelay:2.0 :^{
        [self showEndHintMessageInView:hintView];
    }];
}

@end
