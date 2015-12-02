//    @file:    TGPDiscreteSlider.h
//    @project: TGPControls
//
//    @history: Created November 27, 2014 (Thanksgiving Day)
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

#import "TGPDiscreteSlider7.h"

IB_DESIGNABLE
@interface TGPDiscreteSlider : TGPDiscreteSlider7

@property (nonatomic) IBInspectable int tickStyle;
@property (nonatomic) IBInspectable CGSize tickSize;
@property (nonatomic) IBInspectable int tickCount;
@property (nonatomic) IBInspectable NSString * tickImage;

@property (nonatomic) IBInspectable int trackStyle;
@property (nonatomic) IBInspectable CGFloat trackThickness;
@property (nonatomic) IBInspectable NSString * trackImage;

@property (nonatomic) IBInspectable int thumbStyle;
@property (nonatomic) IBInspectable CGSize thumbSize;
@property (nonatomic) IBInspectable UIColor * thumbColor;
@property (nonatomic) IBInspectable CGFloat thumbSRadius;
@property (nonatomic) IBInspectable CGSize thumbSOffset;
@property (nonatomic) IBInspectable NSString * thumbImage;

// AKA: UISlider value (as CGFloat for compatibility with UISlider API, but expected to contain integers)
@property (nonatomic) IBInspectable CGFloat minimumValue;
@property (nonatomic) IBInspectable CGFloat value;

@property (nonatomic) IBInspectable int incrementValue;

@end
