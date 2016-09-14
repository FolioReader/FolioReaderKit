//
//  FolioReaderQuoteShare.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 8/11/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit


class FolioReaderQuoteShare: UIViewController {
    var quoteText: String!
    var filterImage: UIView!
    var imageView: UIImageView!
    var quoteLabel: UILabel!
    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var logoImageView: UIImageView!
    var collectionView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    let itemSize: CGFloat = 90
    var dataSource = [QuoteImage]()
    let imagePicker = UIImagePickerController()
    var selectedIndex = 0
    
    // MARK: Init
    
    init(initWithText shareText: String) {
        super.init(nibName: nil, bundle: NSBundle.frameworkBundle())
        self.quoteText = shareText.stripLineBreaks().stripHtml()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
        configureNavBar()
        
        let titleAttrs = [NSForegroundColorAttributeName: readerConfig.tintColor]
        let share = UIBarButtonItem(title: readerConfig.localizedShare, style: .Plain, target: self, action: #selector(shareQuote(_:)))
        share.setTitleTextAttributes(titleAttrs, forState: .Normal)
        navigationItem.rightBarButtonItem = share
        
        //
        let screenBounds = UIScreen.mainScreen().bounds
        
        filterImage = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width))
        filterImage.backgroundColor = readerConfig.menuSeparatorColor
        view.addSubview(filterImage)
        
        imageView = UIImageView(frame: filterImage.bounds)
        filterImage.addSubview(imageView)
        
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
        quoteLabel.setContentCompressionResistancePriority(100, forAxis: .Vertical)
        filterImage.addSubview(quoteLabel)
        
        var bookTitle = ""
        var authorName = ""
        
        if let title = book.title() { bookTitle = title }
        if let author = book.metadata.creators.first { authorName = author.name }
        
        titleLabel = UILabel()
        titleLabel.text = bookTitle
        titleLabel.font = UIFont(name: "Lato-Bold", size: 15)
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.numberOfLines = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.setContentCompressionResistancePriority(600, forAxis: .Vertical)
        filterImage.addSubview(titleLabel)
        
        // Attributed author
        let attrs = [NSFontAttributeName: UIFont(name: "Lato-Italic", size: 15)!]
        let attributedString = NSMutableAttributedString(string:"\(readerConfig.localizedShareBy) ", attributes: attrs)
        
        let attrs1 = [NSFontAttributeName: UIFont(name: "Lato-Regular", size: 15)!]
        let boldString = NSMutableAttributedString(string: authorName, attributes:attrs1)
        attributedString.appendAttributedString(boldString)
        
        authorLabel = UILabel()
        authorLabel.attributedText = attributedString
        authorLabel.textAlignment = .Center
        authorLabel.textColor = UIColor.whiteColor()
        authorLabel.numberOfLines = 1
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.adjustsFontSizeToFitWidth = true
        authorLabel.minimumScaleFactor = 0.5
        filterImage.addSubview(authorLabel)
        
        let logoImage = readerConfig.quoteCustomLogoImage
        let logoHeight = logoImage?.size.height ?? 0
        logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .Center
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        filterImage.addSubview(logoImageView)
        
        // Configure layout contraints
        var constraints = [NSLayoutConstraint]()
        let views = [
            "quoteLabel": self.quoteLabel,
            "titleLabel": self.titleLabel,
            "authorLabel": self.authorLabel,
            "logoImageView": self.logoImageView
        ]
        
        NSLayoutConstraint.constraintsWithVisualFormat("V:|-40-[quoteLabel]-20-[titleLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("V:[titleLabel]-0-[authorLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("V:[authorLabel]-25-[logoImageView(\(Int(logoHeight)))]-18-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[quoteLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[titleLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[authorLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[logoImageView]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        filterImage.addConstraints(constraints)
        
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
        dataSource = readerConfig.quoteCustomBackgrounds
        if readerConfig.quotePreserveDefaultBackgrounds {
            createDefaultImages()
        }
        
        // Picker delegate
        imagePicker.delegate = self
        
        // Select first item
        selectIndex(0)
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
    
    func selectIndex(index: Int) {
        let quoteImage = dataSource[index]
        let row = index+1
            
        filterImage.backgroundColor = quoteImage.backgroundColor
        imageView.alpha = quoteImage.alpha
        
        UIView.transitionWithView(filterImage, duration: 0.4, options: .TransitionCrossDissolve, animations: {
            self.imageView.image = quoteImage.image
            self.quoteLabel.textColor = quoteImage.textColor
            self.titleLabel.textColor = quoteImage.textColor
            self.authorLabel.textColor = quoteImage.textColor
            self.logoImageView.image = self.logoImageView.image?.imageTintColor(quoteImage.textColor)
            }, completion: nil)
        
        //
        let prevSelectedIndex = selectedIndex
        selectedIndex = row
        
        guard prevSelectedIndex != selectedIndex else { return }
        
        collectionView.performBatchUpdates({
            self.collectionView.reloadItemsAtIndexPaths([
                NSIndexPath(forItem: self.selectedIndex, inSection: 0),
                NSIndexPath(forItem: prevSelectedIndex, inSection: 0)
            ])
        }, completion: nil)
    }
    
    // MARK: Share
    
    func shareQuote(sender: UIBarButtonItem) {
        var subject = readerConfig.localizedShareHighlightSubject
        var text = ""
        var bookTitle = ""
        var authorName = ""
        var shareItems = [AnyObject]()
        
        // Get book title
        if let title = book.title() {
            bookTitle = title
            subject += " “\(title)”"
        }
        
        // Get author name
        if let author = book.metadata.creators.first {
            authorName = author.name
        }
        
        text = "\(bookTitle) \n\(readerConfig.localizedShareBy) \(authorName)"
        
        let imageQuote = UIImage.imageWithView(filterImage)
        shareItems.append(imageQuote)
        
        if let bookShareLink = readerConfig.localizedShareWebLink {
            text += "\n\(bookShareLink.absoluteString)"
        }
        
        let act = FolioReaderSharingProvider(subject: subject, text: text)
        shareItems.insert(act, atIndex: 0)
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToVimeo]
        
        // Pop style on iPad
        if let actv = activityViewController.popoverPresentationController {
            actv.barButtonItem = sender
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: Status Bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isNight(.LightContent, .Default)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}

// MARK: UICollectionViewDataSource

extension FolioReaderQuoteShare: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        let imageView: UIImageView!
        let tag = 9999
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.contentView.layer.borderWidth = 1
        
        if let view = cell.contentView.viewWithTag(tag) as? UIImageView {
            imageView = view
        } else {
            imageView = UIImageView(frame: cell.bounds)
            imageView.tag = tag
            cell.contentView.addSubview(imageView)
        }
        
        // Image color
        let normalColor = UIColor(white: 0.5, alpha: 0.7)
        let camera = UIImage(readerImageNamed: "icon-camera")
        let dash = UIImage(readerImageNamed: "border-dashed-pattern")
        let cameraNormal = camera!.imageTintColor(normalColor)
        let dashNormal = dash!.imageTintColor(normalColor)
        
        // Camera
        guard indexPath.row > 0 else {
            imageView.contentMode = .Center
            imageView.image = cameraNormal
            cell.contentView.layer.borderColor = UIColor(patternImage: dashNormal).CGColor
            return cell
        }
        
        if selectedIndex == indexPath.row {
            cell.contentView.layer.borderColor = readerConfig.tintColor.CGColor
            cell.contentView.layer.borderWidth = 3
        } else {
            cell.contentView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).CGColor
        }
        
        let quoteImage = dataSource[indexPath.row-1]
        imageView.image = quoteImage.image
        imageView.alpha = quoteImage.alpha
        imageView.contentMode = .ScaleAspectFit
        cell.contentView.backgroundColor = quoteImage.backgroundColor
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: itemSize, height: itemSize)
    }
}

// MARK: UICollectionViewDelegate

extension FolioReaderQuoteShare: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard indexPath.row > 0 else {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let takePhoto = UIAlertAction(title: readerConfig.localizedTakePhoto, style: .Default, handler: { (action) -> Void in
                self.imagePicker.sourceType = .Camera
                self.imagePicker.allowsEditing = true
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            })
            
            let existingPhoto = UIAlertAction(title: readerConfig.localizedChooseExisting, style: .Default) { (action) -> Void in
                self.imagePicker.sourceType = .PhotoLibrary
                self.imagePicker.allowsEditing = true
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
            
            let cancel = UIAlertAction(title: readerConfig.localizedCancel, style: .Cancel, handler: nil)
            
            alertController.addAction(takePhoto)
            alertController.addAction(existingPhoto)
            alertController.addAction(cancel)
            
            presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        selectIndex(indexPath.row-1)
    }
}

// MARK: ImagePicker delegate

extension FolioReaderQuoteShare: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {

            let quoteImage = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.blackColor())

            collectionView.performBatchUpdates({
                self.dataSource.insert(quoteImage, atIndex: 0)
                self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: 1, inSection: 0)])
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: self.selectedIndex, inSection: 0)])
            }, completion: { (finished) in
                self.selectIndex(0)
            })
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}