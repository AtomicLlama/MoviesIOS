/**
 This file is part of the SFFocusViewLayout package.
 (c) Sergio Fernández <fdz.sergio@gmail.com>

 For the full copyright and license information, please view the LICENSE
 file that was distributed with this source code.
 */

import UIKit

protocol CollectionViewCellRender {

    func setTitle(title: String)
    func setDescription(description: String)
    func setBackgroundImage(image: UIImage)
}

class CollectionViewCell: UICollectionViewCell {

    var blurEffectView: UIVisualEffectView?

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var movie: Movie? {
        didSet {
            if let movieUnwrapped = movie {
                setTitle(movieUnwrapped.title)
                setDescription(movieUnwrapped.description)
                setBackgroundImage(movieUnwrapped.detailImage ?? movieUnwrapped.poster ?? UIImage())
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let blurView = UIBlurEffect(style: .Dark)
        overlayView.backgroundColor = UIColor.clearColor()
        blurEffectView = UIVisualEffectView(effect: blurView)
        blurEffectView?.frame = (backgroundImageView.superview?.bounds)!
        if let blur = blurEffectView {
            backgroundImageView.addSubview(blur)
        }
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurView)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = (backgroundImageView.superview?.bounds)!
        overlayView.addSubview(vibrancyView)
        vibrancyView.addSubview(titleLabel)
        vibrancyView.addSubview(descriptionLabel)
    }

    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)

        let featuredHeight: CGFloat = Constant.featuredHeight
        let standardHeight: CGFloat = Constant.standardHegiht

        let delta = 1 - (featuredHeight - CGRectGetHeight(frame)) / (featuredHeight - standardHeight)

        let minAlpha: CGFloat = Constant.minAlpha
        let maxAlpha: CGFloat = Constant.maxAlpha

        let alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        blurEffectView?.alpha = alpha

        let scale = max(delta, 0.5)
        titleLabel.transform = CGAffineTransformMakeScale(scale, scale)

        descriptionLabel.alpha = delta
    }
}

extension CollectionViewCell: CollectionViewCellRender {

    func setTitle(title: String) {
        self.titleLabel.text = title
    }

    func setDescription(description: String) {
        self.descriptionLabel.text = description
    }

    func setBackgroundImage(image: UIImage) {
        self.backgroundImageView.image = image
    }

}

extension CollectionViewCell {
    struct Constant {
        static let featuredHeight: CGFloat = 280
        static let standardHegiht: CGFloat = 100

        static let minAlpha: CGFloat = 0.5
        static let maxAlpha: CGFloat = 0.85
    }
}

extension CollectionViewCell : NibLoadableView { }
