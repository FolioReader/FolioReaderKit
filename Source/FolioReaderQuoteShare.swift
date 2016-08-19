//
//  FolioReaderQuoteShare.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 8/11/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

public struct QuoteImage {
    public var image: UIImage!
    public var textColor: UIColor!
    
    public init(withImage image: UIImage, textColor: UIColor = UIColor.whiteColor()) {
        self.image = image
        self.textColor = textColor
    }
    
    public init(withGradient gradient: CAGradientLayer, textColor: UIColor = UIColor.whiteColor()) {
        let screenBounds = UIScreen.mainScreen().bounds
        gradient.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width)
        self.image = UIImage.imageWithLayer(gradient)
        self.textColor = textColor
    }
    
    public init(withColor color: UIColor, textColor: UIColor = UIColor.whiteColor()) {
        self.image = UIImage.imageWithColor(color)
        self.textColor = textColor
    }
}

class FolioReaderQuoteShare: UIViewController {
    var quoteText: String!
    var imageView: UIImageView!
    var quoteLabel: UILabel!
    var authorLabel: UILabel!
    var logoImageView: UIImageView!
    var collectionView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    let itemSize: CGFloat = 90
    var dataSource = [QuoteImage]()
    
    // MARK: Init
    
    init(initWithText shareText: String) {
        super.init(nibName: nil, bundle: NSBundle.frameworkBundle())
        self.quoteText = shareText.stripLineBreaks().stripHtml()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
        configureNavBar()
        
        title = "Share"
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width))
        imageView.backgroundColor = readerConfig.menuSeparatorColor
        view.addSubview(imageView)
        
        quoteLabel = UILabel()
        quoteLabel.text = quoteText
        quoteLabel.textAlignment = .Center
        quoteLabel.font = UIFont(name: "Andada-Regular", size: 26)
        quoteLabel.textColor = UIColor.whiteColor()
        quoteLabel.numberOfLines = 0
        quoteLabel.baselineAdjustment = .AlignCenters
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.adjustsFontSizeToFitWidth = true
        quoteLabel.minimumScaleFactor = 0.3
//        quoteLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        quoteLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        imageView.addSubview(quoteLabel)
        
        var bookTitle = ""
        var authorName = ""
        
        if let title = book.title() { bookTitle = title }
        if let author = book.metadata.creators.first { authorName = author.name }
        
        authorLabel = UILabel()
        authorLabel.text = "from \(bookTitle) \nby \(authorName)"
        authorLabel.textAlignment = .Center
        authorLabel.font = UIFont(name: "Avenir-Regular", size: 15)
        authorLabel.textColor = UIColor.whiteColor()
        authorLabel.numberOfLines = 2
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
//        quoteLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        quoteLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        imageView.addSubview(authorLabel)
        
        let logoImage = UIImage(readerImageNamed: "icon-logo")
        let logoHeight = logoImage?.size.height ?? 0
        logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .Center
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(logoImageView)
        
        // Configure layout contraints
        var constraints = [NSLayoutConstraint]()
        let views = ["quoteLabel": self.quoteLabel, "authorLabel": self.authorLabel, "logoImageView": self.logoImageView]
        
        NSLayoutConstraint.constraintsWithVisualFormat("V:|-40-[quoteLabel]-20-[authorLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("V:[authorLabel]-25-[logoImageView(\(Int(logoHeight)))]-18-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[quoteLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[authorLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[logoImageView]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        imageView.addConstraints(constraints)
        
        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionViewLayout.minimumLineSpacing = 15
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .Horizontal
        
        let background = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
        view.backgroundColor = background
        
        // CollectionView
        let collectionFrame = CGRect(x: 0, y: imageView.frame.height+15, width: screenBounds.width, height: itemSize)
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.FlexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        view.addSubview(collectionView)
        
        // Register cell classes
        collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Create images
        createDefaultImages()
        
        // Select first item
        setSelectedIndex(0)
    }
    
    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor())
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.whiteColor(), UIColor.blackColor())
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    func createDefaultImages() {
        let color1 = QuoteImage(withColor: UIColor(rgba: "#FA7B67"))
        let color2 = QuoteImage(withColor: UIColor(rgba: "#78CAB6"))
        let color3 = QuoteImage(withColor: UIColor(rgba: "#71B630"))
        let color4 = QuoteImage(withColor: UIColor(rgba: "#4D5B49"))
        let color5 = QuoteImage(withColor: UIColor(rgba: "#959D92"), textColor: UIColor(rgba: "#4D5B49"))
        
        var gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#2989C9").CGColor, UIColor(rgba: "#21B8C2").CGColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        let gradient1 = QuoteImage(withGradient: gradient)
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#FAD961").CGColor, UIColor(rgba: "#F76B1C").CGColor]
        let gradient2 = QuoteImage(withGradient: gradient)
        
        gradient = CAGradientLayer()
        gradient.colors = [UIColor(rgba: "#B4EC51").CGColor, UIColor(rgba: "#429321").CGColor]
        let gradient3 = QuoteImage(withGradient: gradient)
        
        dataSource.appendContentsOf([color1, color2, color3, color4, color5, gradient1, gradient2, gradient3])
    }
    
    func setSelectedIndex(index: Int) {
        let quoteImage = dataSource[index]
        UIView.transitionWithView(imageView, duration: 0.4, options: .TransitionCrossDissolve, animations: {
            self.imageView.image = quoteImage.image
            self.quoteLabel.textColor = quoteImage.textColor
            self.authorLabel.textColor = quoteImage.textColor
            self.logoImageView.image = self.logoImageView.image?.imageTintColor(quoteImage.textColor)
            }, completion: nil)
    }
    
    // MARK: - Status Bar
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isNight(.LightContent, .Default)
    }
}

// MARK: UICollectionViewDataSource

extension FolioReaderQuoteShare: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let quoteImage = dataSource[indexPath.row]
        
        let imageView = UIImageView(frame: cell.bounds)
        imageView.image = quoteImage.image
        cell.contentView.addSubview(imageView)
        
        cell.contentView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).CGColor
        cell.contentView.layer.borderWidth = 1
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: itemSize, height: itemSize)
    }
}

// MARK: UICollectionViewDelegate

extension FolioReaderQuoteShare: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        setSelectedIndex(indexPath.row)
    }
}