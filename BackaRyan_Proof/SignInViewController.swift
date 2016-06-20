//
//  SignInViewController.swift
//  Money Hungry
//
//  Created by Ryan K Backa on 6/16/16.
//  Copyright © 2016 Ryan Backa. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, GIDSignInUIDelegate{
  @IBOutlet weak var signInButton: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    GIDSignIn.sharedInstance().uiDelegate = self
    
    // Uncomment to automatically sign in the user.
    GIDSignIn.sharedInstance().signInSilently()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  

  
  // Stop the UIActivityIndicatorView animation that was started when the user
  // pressed the Sign In button
  func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
    //myActivityIndicator.stopAnimating()
  }
  
  // Present a view that prompts the user to sign in with Google
  func signIn(signIn: GIDSignIn!,
              presentViewController viewController: UIViewController!) {
    self.presentViewController(viewController, animated: true, completion: nil)
    
    print("Sign In Presented")
  }
  
  // Dismiss the "Sign in with Google" view
  func signIn(signIn: GIDSignIn!,
              dismissViewController viewController: UIViewController!) {
    self.dismissViewControllerAnimated(true, completion: nil)
    
    print("Sign In Dismissed")
    
    signInButton.hidden = true
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
