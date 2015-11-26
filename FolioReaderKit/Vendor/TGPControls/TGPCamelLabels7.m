//    @file:    TGPCamelLabels7.m
//    @project: TGPControls
//
//    @history: Created July 4th, 2014 (Independence Day)
//    @author:  Xavier Schott
//              mailto://xschott@gmail.com
//              http://thegothicparty.com
//              tel://+18089383634
//
//    @license: http://opensource.org/licenses/MIT
//    Copyright (c) 2014, Xavier Schott
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

#import "TGPCamelLabels7.h"

@interface TGPCamelLabels7()
@property (nonatomic, assign) NSUInteger lastValue;
@property (nonatomic, retain) NSMutableArray * upLabels;
@property (nonatomic, retain) NSMutableArray * dnLabels;
@end

@implementation TGPCamelLabels7

#pragma mark properties

- (void)setTickCount:(NSUInteger)tickCount {
    // calculated property
    // Put some order to tickCount: 1 >= count >=  128
    const unsigned int count = (unsigned int) MAX(1, MIN(tickCount, 128));
    [self debugNames:count];
    [self layoutTrack];
}

- (NSUInteger)tickCount {
    // Dynamic property
    return [_names count];
}

- (void)setTicksDistance:(CGFloat)ticksDistance {
    _ticksDistance = MAX(0, ticksDistance);
    [self layoutTrack];
}

- (void)setValue:(NSUInteger)value {
    _value = value;
    [self dockEffect:self.animationDuration];
}

- (void)setUpFontName:(NSString *)upFontName {
    _upFontName = upFontName;
    [self layoutTrack];
}

- (void)setUpFontSize:(CGFloat)upFontSize {
    _upFontSize = upFontSize;
    [self layoutTrack];
}

- (void)setUpFontColor:(UIColor *)upFontColor {
    _upFontColor = upFontColor;
    [self layoutTrack];
}

- (void)setDownFontName:(NSString *)downFontName {
    _downFontName = downFontName;
    [self layoutTrack];
}

- (void)setDownFontSize:(CGFloat)downFontSize {
    _downFontSize = downFontSize;
    [self layoutTrack];
}

- (void)setDownFontColor:(UIColor *)downFontColor {
    _downFontColor = downFontColor;
    [self layoutTrack];
}

// NSArray<NSString*>
- (void)setNames:(NSArray *)names {
    NSAssert(names.count > 0, @"names.count");
    _names = names;
    [self layoutTrack];
}

#pragma mark UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
        [self initProperties];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self != nil) {
        [self initProperties];
    }
    return self;
}

// When bounds change, recalculate layout
- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self layoutTrack];
    [self setNeedsDisplay];
}

// clickthrough
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews) {
        if (!view.hidden && view.alpha > 0 && view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event])
            return YES;
    }
    return NO;
}

#pragma mark TGPCamelLabels

- (void)initProperties {
    _ticksDistance = 44.0;
    _value = 0;
    [self debugNames:10];

    _upFontName = nil;
    _upFontSize = 12;
    _upFontColor = nil;

    _downFontName = nil;
    _downFontSize = 12;
    _downFontColor = nil;

    _upLabels = [NSMutableArray array];
    _dnLabels = [NSMutableArray array];

    _lastValue = NSNotFound;    // Never tapped
    _animationDuration = 0.15;

    [self layoutTrack];
}

- (void)debugNames:(unsigned int)count {
    // Dynamic property, will create an array with labels, generally for debugging purposes
    const NSMutableArray * array = [NSMutableArray array];
    for(int iterate = 1; iterate <= count; iterate++) {
        [array addObject:[NSString stringWithFormat:@"%d", iterate ]];
    }
    [self setNames:(NSArray *) array];
}

- (void)layoutTrack {
    [self.upLabels enumerateObjectsUsingBlock:^(UIView * view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [self.upLabels removeAllObjects];
    [self.dnLabels enumerateObjectsUsingBlock:^(UIView * view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    [self.dnLabels removeAllObjects];

    const NSUInteger count = self.names.count;
    if( count > 0) {
        CGFloat centerX = (self.bounds.size.width - ((count - 1) * self.ticksDistance))/2.0;
        const CGFloat centerY = self.bounds.size.height / 2.0;
        for(NSString * name in self.names) {
            UILabel * upLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.upLabels addObject:upLabel];
            upLabel.text = name;
            upLabel.font = ((self.upFontName != nil)
                            ? [UIFont fontWithName:self.upFontName size:self.upFontSize]
                            : [UIFont boldSystemFontOfSize:self.upFontSize]);
            upLabel.textColor = ((self.upFontColor != nil)
                                 ? self.upFontColor
                                 : self.tintColor);
            [upLabel sizeToFit];
            upLabel.center = CGPointMake(centerX, centerY);
            upLabel.frame = ({
                CGRect frame = upLabel.frame;
                // frame.origin.y = 0;
                frame.origin.y = self.bounds.size.height - frame.size.height;
                frame;
            });
            upLabel.alpha = 0.0;
            [self addSubview:upLabel];

            UILabel * dnLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.dnLabels addObject:dnLabel];
            dnLabel.text = name;
            dnLabel.font = ((self.downFontName != nil)
                            ? [UIFont fontWithName:self.downFontName size:self.downFontSize]
                            : [UIFont boldSystemFontOfSize:self.downFontSize]);
            dnLabel.textColor = ((self.downFontColor != nil)
                                 ? self.downFontColor
                                 : [UIColor grayColor]);
            [dnLabel sizeToFit];
            dnLabel.center = CGPointMake(centerX, centerY);
            dnLabel.frame = ({
                CGRect frame = dnLabel.frame;
                frame.origin.y = self.bounds.size.height - frame.size.height;
                frame;
            });
            [self addSubview:dnLabel];

            centerX += self.ticksDistance;
        }
        [self dockEffect:0.0];
    }
}

- (void)dockEffect:(NSTimeInterval)duration
{
    const NSUInteger up = self.value;

    // Unlike the National Parks from which it is inspired, this Dock Effect
    // does not abruptly change from BOLD to plain. Instead, we have 2 sets of
    // labels, which are faded back and forth, in unisson.
    // - BOLD to plain
    // - Black to gray
    // - high to low
    // Each animation picks up where the previous left off
    void (^moveBlock)() = ^void() {
        // Bring almost all down
        [self.upLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if( up != idx) {
                [self moveDown:obj withAlpha:0.f];
            }
        }];
        [self.dnLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if( up != idx) {
                [self moveDown:obj withAlpha:1.f];
            }
        }];

        // Bring the selection up
        if(up < [self.upLabels count]) {
            [self moveUp:[self.upLabels objectAtIndex:up] withAlpha:1.f];
        }
        if(up < [self.dnLabels count]) {
            [self moveUp:[self.dnLabels objectAtIndex:up] withAlpha:0.f];
        }
    };

    if(duration > 0) {
        [UIView animateWithDuration:duration
                        delay:0
                            options:(UIViewAnimationOptionBeginFromCurrentState +
                                     UIViewAnimationOptionCurveLinear)
                         animations:moveBlock
                         completion:nil];
    } else {
        moveBlock();
    }
}

- (void)moveDown:(UIView*)aView withAlpha:(CGFloat) alpha
{
    aView.frame = ({
        CGRect frame = aView.frame;
        frame.origin.y = self.bounds.size.height - frame.size.height;
        frame;
    });
    [aView setAlpha:alpha];
}

- (void)moveUp:(UIView*)aView withAlpha:(CGFloat) alpha
{
    aView.frame = ({
        CGRect frame = aView.frame;
        frame.origin.y = 0;
        frame;
    });
    [aView setAlpha:alpha];
}

#pragma mark - TGPControlsTicksProtocol

- (void)tgpTicksDistanceChanged:(CGFloat)ticksDistance sender:(id)sender
{
    self.ticksDistance = ticksDistance;
}

- (void)tgpValueChanged:(unsigned int)value
{
    self.value = value;
}
@end
