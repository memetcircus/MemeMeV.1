//
//  ViewController.swift
//  MemeMe
//
//  Created by Mehmet Akif Acar on 05/08/15.
//  Copyright (c) 2015 Memetcircus. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolbar: UIToolbar!
  
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var actionTopToolBarItem: UIBarButtonItem!
    
    @IBOutlet weak var cancelTopToolBarItem: UIBarButtonItem!
    
    @IBOutlet weak var cameraBottonBarItem: UIBarButtonItem!
    
    @IBOutlet weak var albumBottomBarItem: UIBarButtonItem!
    
    let textFieldAttributes = [
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeColorAttributeName:UIColor.blackColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -4.4
    ]
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        ///clean textfields when editing begins
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
    }
    
    /// if nothing is inserted, turn textfields to default text
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField.text!.isEmpty{
            if textField == topTextField{
                textField.text = "TOP"
            }
            else{
                textField.text = "BOTTOM"
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = UIApplication.sharedApplication().delegate as! AppDelegate
        
        ///do not allow save and cancel view if no image is selected
        if let _ = imagePickerView.image{
            actionTopToolBarItem.enabled = true
            cancelTopToolBarItem.enabled = true
        }
        else{
            actionTopToolBarItem.enabled = false
            cancelTopToolBarItem.enabled = false
        }
        
        ///set textfield type to impact type
        topTextField.defaultTextAttributes = textFieldAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.defaultTextAttributes = textFieldAttributes
        bottomTextField.textAlignment = NSTextAlignment.Center
        
        ///if camera not available, disable camera button
        cameraBottonBarItem.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        self.subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
    }

    ///shift image up to see the bottom entered text
    func keyboardWillShow(notification: NSNotification){
        
        if bottomTextField.isFirstResponder(){
             self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    ///shift image to original
    func keyboardWillDisappear(notification: NSNotification){
        
         if bottomTextField.isFirstResponder(){
            self.view.frame.origin.y += getKeyboardHeight(notification)
         }
    }
    
    func getKeyboardHeight (notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func unsubscribeFromKeyboardNotifications(){
       
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification , object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification , object: nil)
    }

    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        
        self.pickAnImageFromWhichSourceTypeAndPresentPickerView(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        
        self.pickAnImageFromWhichSourceTypeAndPresentPickerView(UIImagePickerControllerSourceType.Camera)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickAnImageFromWhichSourceTypeAndPresentPickerView(sourceType: UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    ///save memed image and related text to appdelegate array
    func save(passedMemedImage : UIImage) {
        
        let meme = Meme(bottomText: bottomTextField.text!, topText: topTextField.text!, orgImage: imagePickerView.image!, memedImage: passedMemedImage)
    
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.append(meme)
    }
 
    @IBAction func shareTheMemedImage(sender: AnyObject) {
        
        let memedImage : UIImage = self.generateMemedImage()
        
        let nextController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        ///exclude some types from the share options
        nextController.excludedActivityTypes = [
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        self.presentViewController(nextController, animated: true, completion: nil)
        
        ///after picking image is finished, save the memedImage and dismiss the pickerview
        nextController.completionWithItemsHandler = {
            (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                self.save(memedImage)
                self.dismissViewControllerAnimated(true, completion:nil)
            }
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolbar.hidden = true
        bottomToolbar.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topToolbar.hidden = false
        bottomToolbar.hidden = false
    
        return memedImage
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            self.imagePickerView.image = image
        }
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelEdit(sender: AnyObject) {

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///reset view to original state
    @IBAction func cancelTouchedInEditorView(sender: AnyObject) {
        
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        actionTopToolBarItem.enabled = false
        cancelTopToolBarItem.enabled = false
    }

}

