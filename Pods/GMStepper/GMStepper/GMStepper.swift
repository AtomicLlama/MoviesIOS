//
//  GMStepper.swift
//  GMStepper
//
//  Created by Gunay Mert Karadogan on 1/7/15.
//  Copyright © 2015 Gunay Mert Karadogan. All rights reserved.
//

import UIKit

@IBDesignable public class GMStepper: UIControl {

    /// Current value of the stepper. Defaults to 0.
    @IBInspectable public var value: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))

            let isInteger = floor(value) == value

            if showIntegerIfDoubleIsInteger && isInteger {
                label.text = String(stringInterpolationSegment: Int(value))
            } else {
                label.text = String(stringInterpolationSegment: value)
            }

            if oldValue != value {
                sendActionsForControlEvents(.ValueChanged)
            }
        }
    }

    /// Minimum value. Must be less than maximumValue. Defaults to 0.
    @IBInspectable public var minimumValue: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }

    /// Maximum value. Must be more than minimumValue. Defaults to 100.
    @IBInspectable public var maximumValue: Double = 100 {
        didSet {
            value = min(maximumValue, max(minimumValue, value))
        }
    }

    /// Step/Increment value as in UIStepper. Defaults to 1.
    @IBInspectable public var stepValue: Double = 1

    /// The same as UIStepper's autorepeat. If true, holding on the buttons or keeping the pan gesture alters the value repeatedly. Defaults to true.
    @IBInspectable public var autorepeat: Bool = true

    /// If the value is integer, it is shown without floating point.
    @IBInspectable public var showIntegerIfDoubleIsInteger: Bool = true

    /// Text on the left button. Be sure that it fits in the button. Defaults to "-".
    @IBInspectable public var leftButtonText: String = "-" {
        didSet {
            leftButton.setTitle(leftButtonText, forState: .Normal)
        }
    }

    /// Text on the right button. Be sure that it fits in the button. Defaults to "+".
    @IBInspectable public var rightButtonText: String = "+" {
        didSet {
            rightButton.setTitle(rightButtonText, forState: .Normal)
        }
    }

    /// Text color of the buttons. Defaults to white.
    @IBInspectable public var buttonsTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            for button in [leftButton, rightButton] {
                button.setTitleColor(buttonsTextColor, forState: .Normal)
            }
        }
    }

    /// Background color of the buttons. Defaults to dark blue.
    @IBInspectable public var buttonsBackgroundColor: UIColor = UIColor(red:0.21, green:0.5, blue:0.74, alpha:1) {
        didSet {
            for button in [leftButton, rightButton] {
                button.backgroundColor = buttonsBackgroundColor
            }
            backgroundColor = buttonsBackgroundColor
        }
    }

    /// Font of the buttons. Defaults to AvenirNext-Bold, 20.0 points in size.
    public var buttonsFont = UIFont(name: "AvenirNext-Bold", size: 20.0)! {
        didSet {
            for button in [leftButton, rightButton] {
                button.titleLabel?.font = buttonsFont
            }
        }
    }

    /// Text color of the middle label. Defaults to white.
    @IBInspectable public var labelTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            label.textColor = labelTextColor
        }
    }

    /// Text color of the middle label. Defaults to lighter blue.
    @IBInspectable public var labelBackgroundColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1) {
        didSet {
            label.backgroundColor = labelBackgroundColor
        }
    }

    /// Font of the middle label. Defaults to AvenirNext-Bold, 25.0 points in size.
    public var labelFont = UIFont(name: "AvenirNext-Bold", size: 25.0)! {
        didSet {
            label.font = labelFont
        }
    }

    /// Corner radius of the stepper's layer. Defaults to 4.0.
    @IBInspectable public var cornerRadius: CGFloat = 4.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }

    /// Percentage of the middle label's width. Must be between 0 and 1. Defaults to 0.5. Be sure that it is wide enough to show the value.
    @IBInspectable public var labelWidthWeight: CGFloat = 0.5 {
        didSet {
            labelWidthWeight = min(1, max(0, labelWidthWeight))
            setNeedsLayout()
        }
    }

    /// Color of the flashing animation on the buttons in case the value hit the limit.
    @IBInspectable public var limitHitAnimationColor: UIColor = UIColor(red:0.26, green:0.6, blue:0.87, alpha:1)

    /**
        Width of the sliding animation. When buttons clicked, the middle label does a slide animation towards to the clicked button. Defaults to 5.
    */
    let labelSlideLength: CGFloat = 5

    /// Duration of the sliding animation
    let labelSlideDuration = NSTimeInterval(0.1)

    /// Duration of the animation when the value hits the limit.
    let limitHitAnimationDuration = NSTimeInterval(0.1)

    lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.leftButtonText, forState: .Normal)
        button.setTitleColor(self.buttonsTextColor, forState: .Normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: "leftButtonTouchDown:", forControlEvents: .TouchDown)
        button.addTarget(self, action: "buttonTouchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "buttonTouchUp:", forControlEvents: UIControlEvents.TouchUpOutside)
        return button
    }()

    lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitle(self.rightButtonText, forState: .Normal)
        button.setTitleColor(self.buttonsTextColor, forState: .Normal)
        button.backgroundColor = self.buttonsBackgroundColor
        button.titleLabel?.font = self.buttonsFont
        button.addTarget(self, action: "rightButtonTouchDown:", forControlEvents: .TouchDown)
        button.addTarget(self, action: "buttonTouchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "buttonTouchUp:", forControlEvents: UIControlEvents.TouchUpOutside)
        return button
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        if self.showIntegerIfDoubleIsInteger && floor(self.value) == self.value {
            label.text = String(stringInterpolationSegment: Int(self.value))
        } else {
            label.text = String(stringInterpolationSegment: self.value)
        }
        label.textColor = self.labelTextColor
        label.backgroundColor = self.labelBackgroundColor
        label.font = self.labelFont
        label.userInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        panRecognizer.maximumNumberOfTouches = 1
        label.addGestureRecognizer(panRecognizer)
        return label
    }()

    var labelOriginalCenter: CGPoint!
    var labelMaximumCenterX: CGFloat!
    var labelMinimumCenterX: CGFloat!

    enum LabelPanState {
        case Stable, HitRightEdge, HitLeftEdge
    }
    var panState = LabelPanState.Stable

    enum StepperState {
        case Stable, ShouldIncrease, ShouldDecrease
    }
    var stepperState = StepperState.Stable {
        didSet {
            if stepperState != .Stable {
                updateValue()
                if autorepeat {
                    scheduleTimer()
                }
            }
        }
    }

    /// Timer used for autorepeat option
    var timer: NSTimer?

    /** When UIStepper reaches its top speed, it alters the value with a time interval of ~0.05 sec.
        The user pressing and holding on the stepper repeatedly:
        - First 2.5 sec, the stepper changes the value every 0.5 sec.
        - For the next 1.5 sec, it changes the value every 0.1 sec.
        - Then, every 0.05 sec.
    */
    let timerInterval = NSTimeInterval(0.05)

    /// Check the handleTimerFire: function. While it is counting the number of fires, it decreases the mod value so that the value is altered more frequently.
    var timerFireCount = 0
    var timerFireCountModulo: Int {
        if timerFireCount > 80 {
            return 1 // 0.05 sec * 1 = 0.05 sec
        } else if timerFireCount > 50 {
            return 2 // 0.05 sec * 2 = 0.1 sec
        } else {
            return 10 // 0.05 sec * 10 = 0.5 sec
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(label)

        backgroundColor = buttonsBackgroundColor
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reset", name: UIApplicationWillResignActiveNotification, object: nil)
    }

    public override func layoutSubviews() {
        let buttonWidth = bounds.size.width * ((1 - labelWidthWeight) / 2)
        let labelWidth = bounds.size.width * labelWidthWeight

        leftButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.size.height)
        label.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.size.height)
        rightButton.frame = CGRect(x: labelWidth + buttonWidth, y: 0, width: buttonWidth, height: bounds.size.height)

        labelMaximumCenterX = label.center.x + labelSlideLength
        labelMinimumCenterX = label.center.x - labelSlideLength
        labelOriginalCenter = label.center
    }

    func updateValue() {
        if stepperState == .ShouldIncrease {
            value += stepValue
        } else if stepperState == .ShouldDecrease {
            value -= stepValue
        }   
    }

    deinit {
        resetTimer()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /// Useful closure for logging the timer interval. You can call this in the timer handler to test the autorepeat option. Not used in the current implementation.
//    lazy var printTimerGaps: () -> () = {
//        var prevTime: CFAbsoluteTime?
//
//        return { _ in
//            var now = CFAbsoluteTimeGetCurrent()
//            if let prevTime = prevTime {
//                print(now - prevTime)
//            }
//            prevTime = now
//        }
//    }()
}

// MARK: Pan Gesture
extension GMStepper {
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            leftButton.enabled = false
            rightButton.enabled = false
        case .Changed:
            let translation = gesture.translationInView(label)
            gesture.setTranslation(CGPointZero, inView: label)

            let slidingRight = gesture.velocityInView(label).x > 0
            let slidingLeft = gesture.velocityInView(label).x < 0

            // Move the label with pan
            if slidingRight {
                label.center.x = min(labelMaximumCenterX, label.center.x + translation.x)
            } else if slidingLeft {
                label.center.x = max(labelMinimumCenterX, label.center.x + translation.x)
            }

            // When the label hits the edges, increase/decrease value and change button backgrounds
            if label.center.x == labelMaximumCenterX {
                // If not hit the right edge before, increase the value and start the timer. If already hit the edge, do nothing. Timer will handle it.
                if panState != .HitRightEdge {
                    stepperState = .ShouldIncrease
                    panState = .HitRightEdge
                }
                
                animateLimitHitIfNeeded()
            } else if label.center.x == labelMinimumCenterX {
                if panState != .HitLeftEdge {
                    stepperState = .ShouldDecrease
                    panState = .HitLeftEdge
                }

                animateLimitHitIfNeeded()
            } else {
                panState = .Stable
                stepperState = .Stable
                resetTimer()

                self.rightButton.backgroundColor = self.buttonsBackgroundColor
                self.leftButton.backgroundColor = self.buttonsBackgroundColor
            }
        case .Ended, .Cancelled, .Failed:
            reset()
        default:
            break
        }
    }

    func reset() {
        panState = .Stable
        stepperState = .Stable
        resetTimer()

        leftButton.enabled = true
        rightButton.enabled = true
        label.userInteractionEnabled = true

        UIView.animateWithDuration(self.labelSlideDuration, animations: {
            self.label.center = self.labelOriginalCenter
            self.rightButton.backgroundColor = self.buttonsBackgroundColor
            self.leftButton.backgroundColor = self.buttonsBackgroundColor
        })
    }
}

// MARK: Button Events
extension GMStepper {
    func leftButtonTouchDown(button: UIButton) {
        rightButton.enabled = false
        label.userInteractionEnabled = false
        resetTimer()

        if value == minimumValue {
            animateLimitHitIfNeeded()
        } else {
            stepperState = .ShouldDecrease
            animateSlideLeft()
        }

    }

    func rightButtonTouchDown(button: UIButton) {
        leftButton.enabled = false
        label.userInteractionEnabled = false
        resetTimer()

        if value == maximumValue {
            animateLimitHitIfNeeded()
        } else {
            stepperState = .ShouldIncrease
            animateSlideRight()
        }
    }

    func buttonTouchUp(button: UIButton) {
        reset()
    }
}

// MARK: Animations
extension GMStepper {

    func animateSlideLeft() {
        UIView.animateWithDuration(labelSlideDuration) {
            self.label.center.x -= self.labelSlideLength
        }
    }

    func animateSlideRight() {
        UIView.animateWithDuration(labelSlideDuration) {
            self.label.center.x += self.labelSlideLength
        }
    }

    func animateToOriginalPosition() {
        if self.label.center != self.labelOriginalCenter {
            UIView.animateWithDuration(labelSlideDuration) {
                self.label.center = self.labelOriginalCenter
            }
        }
    }

    func animateLimitHitIfNeeded() {
        if value == minimumValue {
            animateLimitHitForButton(leftButton)
        } else if value == maximumValue {
            animateLimitHitForButton(rightButton)
        }
    }

    func animateLimitHitForButton(button: UIButton){
        UIView.animateWithDuration(limitHitAnimationDuration) {
            button.backgroundColor = self.limitHitAnimationColor
        }
    }
}

// MARK: Timer
extension GMStepper {
    func handleTimerFire(timer: NSTimer) {
        timerFireCount += 1

        if timerFireCount % timerFireCountModulo == 0 {
            updateValue()
        }
    }

    func scheduleTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "handleTimerFire:", userInfo: nil, repeats: true)
    }

    func resetTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            timerFireCount = 0
        }
    }


}