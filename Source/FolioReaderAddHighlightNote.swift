
import UIKit
import RealmSwift

class FolioReaderAddHighlightNote: UIViewController {
    
    var textView : UITextView!
    var highlightLabel : UILabel!
    var scrollView : UIScrollView!
    var containerView = UIView()
    var highlight : Highlight!
    var highlightSaved = false
    var editHighlight = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setCloseButton()
        prepareScrollView()
        configureView()
        configureNavBar()
        configureNotification()

        let titleAttrs = [NSForegroundColorAttributeName: readerConfig.tintColor]
        let save = UIBarButtonItem(title: readerConfig.localizedSave, style: .plain, target: self, action: #selector(saveNote(_:)))
        save.setTitleTextAttributes(titleAttrs, for: UIControlState())
        navigationItem.rightBarButtonItem = save
        
    }
    
    init(initWithHighlight highlight: Highlight) {
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
        self.highlight = highlight
//        self.quoteText = shareText.stripLineBreaks().stripHtml()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        setNeedsStatusBarAppearanceUpdate()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !self.highlightSaved && !editHighlight{
            guard let currentPage = FolioReader.shared.readerCenter?.currentPage else { return }
            currentPage.webView.js("removeThisHighlight()")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = view.bounds
        scrollView.contentSize = view.bounds.size
    }
    
    func prepareScrollView(){
        
        var leftConstraint : NSLayoutConstraint
        var rightConstraint : NSLayoutConstraint
        var topConstraint : NSLayoutConstraint
        var botConstraint : NSLayoutConstraint
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.contentSize = CGSize.init(width: view.frame.width, height: view.frame.height )
        scrollView.bounces = false
        
        containerView = UIView()
        containerView.backgroundColor = .white
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        leftConstraint = NSLayoutConstraint.init(item: scrollView!, attribute: .left, relatedBy: .equal,
                                                 toItem: view, attribute: .left,
                                                 multiplier: 1.0, constant: 0)
        
        rightConstraint = NSLayoutConstraint.init(item: scrollView!, attribute: .right, relatedBy: .equal,
                                                  toItem: view, attribute: .right,
                                                  multiplier: 1.0, constant: 0)
        
        topConstraint = NSLayoutConstraint.init(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        
        botConstraint = NSLayoutConstraint.init(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, botConstraint])
        
    }
    
    func configureView(){
        
        //constraints for views
        var leftConstraint : NSLayoutConstraint
        var rightConstraint : NSLayoutConstraint
        var topConstraint : NSLayoutConstraint
        var heiConstraint : NSLayoutConstraint
        
        //Text View
        textView = UITextView()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .black
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        containerView.addSubview(textView)
        
        if editHighlight {
            textView.text = highlight.noteForHighlight
        }
        
        leftConstraint = NSLayoutConstraint.init(item: textView!, attribute: .left, relatedBy: .equal,
                                                 toItem: containerView, attribute: .left,
                                                 multiplier: 1.0, constant: 20)
        
        rightConstraint = NSLayoutConstraint.init(item: textView!, attribute: .right, relatedBy: .equal,
                                                  toItem: containerView, attribute: .right,
                                                  multiplier: 1.0, constant: -20)
        
        topConstraint = NSLayoutConstraint.init(item: textView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 100)
        
        heiConstraint = NSLayoutConstraint.init(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height - 100)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
        
        
        
        //UIlabel
        highlightLabel = UILabel()
        highlightLabel.translatesAutoresizingMaskIntoConstraints = false
        highlightLabel.numberOfLines = 3
        highlightLabel.font = UIFont.systemFont(ofSize: 15)
        highlightLabel.text = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        
        containerView.addSubview(self.highlightLabel!)
        
        leftConstraint = NSLayoutConstraint.init(item: highlightLabel!, attribute: .left, relatedBy: .equal,
                                                 toItem: containerView, attribute: .left,
                                                 multiplier: 1.0, constant: 20)
        
        rightConstraint = NSLayoutConstraint.init(item: highlightLabel!, attribute: .right, relatedBy: .equal,
                                                  toItem: containerView, attribute: .right,
                                                  multiplier: 1.0, constant: -20)
        
        topConstraint = NSLayoutConstraint.init(item: highlightLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 20)
        
        heiConstraint = NSLayoutConstraint.init(item: highlightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 70)
        
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
    }
    
    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.white)
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    func configureNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    func saveNote(_ sender: UIBarButtonItem) {
        
        if textView.text != "" {
            
            if editHighlight {
                
                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
                realm.beginWrite()
                
                self.highlight.noteForHighlight = textView.text
                highlightSaved = true
                
                try! realm.commitWrite()
            }
            else
            {
                self.highlight.noteForHighlight = textView.text
                self.highlight.persist()
                highlightSaved = true
            }
        }
        
        dismiss()
    }

}

extension FolioReaderAddHighlightNote: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 15)
        textView.frame = newFrame;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        textView.frame.size.height = textView.frame.height + 30
        
        if textView.text.characters.count > 0 {
            scrollView.scrollRectToVisible(textView.frame, animated: true)
        }
        
        return true
    }
}
