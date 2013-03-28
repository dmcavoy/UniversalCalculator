//
//  GraphView.m
//  McAvoyGraphingCalculator
//
//  Created by Danielle McAvoy on 3/2/13.
//  Copyright (c) 2013 edu.bowdoin.csci281.mcavoy. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView
@synthesize scale = _scale;
@synthesize origin = _origin;

#define DEFAULT_SCALE 45
#define MAX_GRAPH_SCALE 55
#define MIN_GRAPH_SCALE 0.25


- (CGFloat)scale
{
    if (!_scale) {
        return DEFAULT_SCALE; // don't allow zero scale
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale > MAX_GRAPH_SCALE){
        scale = MAX_GRAPH_SCALE;
    }
    if (scale < MIN_GRAPH_SCALE){
        scale = MIN_GRAPH_SCALE;
    }
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

-(CGPoint)origin
{
    if(CGPointEqualToPoint(CGPointZero, _origin)){
        
        return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    }
    else{
        return _origin;
    }
}

-(void)setOrigin:(CGPoint)origin
{
    if(!CGPointEqualToPoint(origin, _origin)){
        _origin = origin;
        [self setNeedsDisplay];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

-(void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView: self];
        CGPoint newPoint;
        newPoint.x = self.origin.x + translation.x;
        newPoint.y = self.origin.y + translation.y;
        self.origin = newPoint;
        [gesture setTranslation:CGPointZero inView:self]; // need to reset or compounds
    }
}

-(void)doubleTap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = CGPointZero;
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)awakeFromNib
{
    self.contentMode = UIViewContentModeRedraw;
}

/*
 Overrides the built in drawRect to create a graph. Draws
 the axes as well as the graph.
 */
- (void)drawRect:(CGRect)rect
{
    // figure out size
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) {
        size = self.bounds.size.height / 2;
    }
    size *= self.scale;
    
    // Draw Axes
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    CGContextBeginPath(context);
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:self.origin scale:self.scale];
    CGContextStrokePath(context);

    // Create Graph of Expression
    [self createGraphWithMidpoint:self.origin andContext:context];
    
}

/*
 Creates a graph for whatever expression was on the calculator when the
 graph button was pressed.  It uses pixels on the screen, gets the point 
 value, asks the delegate for the y value and then graphs the points.
 
 Parameters
 midPoint -> middle of the graph
 context -> current context
 */

-(void)createGraphWithMidpoint:(CGPoint) midPoint andContext:(CGContextRef) context{

    UIGraphicsPushContext(context);

    // Specifics for the current device
    CGFloat numberOfPoints = self.bounds.size.width /self.scale;
    CGFloat lowestValue = -(numberOfPoints/2);
    CGFloat scaleFactor = self.contentScaleFactor;
    CGFloat numberOfPixels = scaleFactor * self.bounds.size.width;
    
    CGPoint startPixel ;
    CGPoint startPoint = [self convertPixelsToPoint:startPixel withOrigin: midPoint];
    
    startPoint = [self.delegate nextYForGraphView:self usingXValue: lowestValue];
    startPixel = [self convertPointForDrawing: startPoint withOrigin:midPoint];
    
    CGPoint nextPixel;
   
    // Iterates over the pixels across the screen and draws the line
    // between two neighboring pixels
    for (nextPixel.x = 0; (nextPixel.x < numberOfPixels); (nextPixel.x)++) {
        
        CGPoint nextPoint = [self convertPixelsToPoint:nextPixel withOrigin: midPoint];
    
        nextPoint= [self.delegate nextYForGraphView:self usingXValue: nextPoint.x];

        [self drawLineFromPoint:
            [self convertPointForDrawing:startPoint withOrigin: midPoint] toPoint:
            [self convertPointForDrawing:nextPoint withOrigin: midPoint] withContext:context];

        startPoint = nextPoint;
    }

    UIGraphicsPopContext();
}

/*
 Converts point values (graph terms) to pixel values (display terms).
 Because of the way XCode graphics are set up the y value needs to be
 negative.
 
 Parameters
 pixel -> point to convert
 origin -> middle of the graph
 
 Return
 CGPoint -> pixel value that point value was converted to
 */
-(CGPoint)convertPointForDrawing:(CGPoint)point withOrigin: (CGPoint) origin {
    CGPoint gridPoint;
    gridPoint.x = (point.x * self.scale) + origin.x;
    gridPoint.y = (point.y * -self.scale) + origin.y;
    return gridPoint;
}

/*
 Converts pixel values (display terms) to point values (graph terms).
 
 Parameters
 pixel -> pixel to convert
 origin -> middle of the graph
 
 Return
 CGPoint -> point value that pixel value was converted to
 */

-(CGPoint)convertPixelsToPoint:(CGPoint)pixel withOrigin:(CGPoint) origin{
    CGPoint point;
    point.x = (pixel.x - origin.x)/self.scale;
    point.y = (pixel.y - origin.y)/self.scale;
    return point;
}

/*
 Draws a blue line between startPoint and endPoint.
 
 Parameters
 startPoint -> start point of line
 endPoint -> end point of line
 context -> current context
 
 */

- (void)drawLineFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint withContext:(CGContextRef)context
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(currentContext);
    CGContextSetLineWidth(currentContext, 1.0);
    [[UIColor blueColor] setStroke];
	CGContextBeginPath(currentContext);
	CGContextMoveToPoint(currentContext, startPoint.x, startPoint.y);
	CGContextAddLineToPoint(currentContext, endPoint.x, endPoint.y);
	CGContextStrokePath(currentContext);
	UIGraphicsPopContext();
}


@end
