 

import UIKit

class ViewController: UIViewController {

    // MARK: IBOutlet Properties
    
    @IBOutlet weak var btnSignIn: UIButton!
    
    @IBOutlet weak var btnGetProfileInfo: UIButton!
    
    @IBOutlet weak var btnOpenProfile: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnSignIn.enabled = true
        btnGetProfileInfo.enabled = false
        //btnOpenProfile.hidden = true
    }

    @IBAction func signInAction(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForExistingAccessToken()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: IBAction Functions

    @IBAction func getProfileInfo(sender: AnyObject) {
        if let accessToken = NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") {
            // Specify the URL string that we'll get the profile info from.
            let targetURLString = "https://api.linkedin.com/v1/people/~:(id,headline,picture-url,summary,first-name,last-name,formatted-name,location:(name),industry,positions,num-connections,num-connections-capped,api-standard-profile-request:(url,headers),public-profile-url)?format=json"
            
           // Currently (but not usually), if you call the following url you get an internal server error: https://api.linkedin.com/v1/people/~/connections:(id,headline,picture-url,summary,first-name,last-name,formatted-name,location:(name),industry,positions,num-connections,num-connections-capped,api-standard-profile-request:(url,headers),public-profile-url)?format=json
            
            // Initialize a mutable URL request object.
            let request = NSMutableURLRequest(URL: NSURL(string: targetURLString)!)
            
            // Indicate that this is a GET request.
            request.HTTPMethod = "GET"
            
            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            // Initialize a NSURLSession object.
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            // Make the request.
            let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    do {
                        let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        
                        let profileURLString = dataDictionary["formattedName"] as! String
                        let profileURLString1 = dataDictionary["headline"] as! String
                        let profileURLString2 = dataDictionary["industry"] as! String
                        let profileURLString3 = dataDictionary["publicProfileUrl"] as! String
                        
                        
                        print(dataDictionary)
                        
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.textView.text = "\(profileURLString)\n\(profileURLString1)\n\(profileURLString2)\n\(profileURLString3)"
                            self.textView.backgroundColor = UIColor.lightGrayColor()
                        })
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    @IBAction func openProfileInSafari(sender: AnyObject) {
        let profileURL = NSURL(string: btnOpenProfile.titleForState(UIControlState.Normal)!)
        UIApplication.sharedApplication().openURL(profileURL!)
    }
 
    
    // MARK: Custom Functions
    
    func checkForExistingAccessToken() {
        if NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") != nil {
            btnSignIn.enabled = false
            btnGetProfileInfo.enabled = true
        }
    }
    
}




