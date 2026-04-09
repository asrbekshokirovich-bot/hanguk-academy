import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  var blurEffectView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Listen for screen recording/casting
    NotificationCenter.default.addObserver(self, selector: #selector(preventScreenRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    
    // Mask the screen when entering App Switcher
    NotificationCenter.default.addObserver(self, selector: #selector(addBlur), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(removeBlur), name: UIApplication.didBecomeActiveNotification, object: nil)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc func preventScreenRecording() {
    // If the OS declares the screen is being captured (recording/AirPlay), blur the screen natively
    if UIScreen.main.isCaptured {
      addBlur()
    } else {
      removeBlur()
    }
  }

  @objc func addBlur() {
    if blurEffectView == nil, let window = self.window {
      let blurEffect = UIBlurEffect(style: .dark)
      blurEffectView = UIVisualEffectView(effect: blurEffect)
      blurEffectView?.frame = window.bounds
      blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      // Explicit warning layer
      let label = UILabel()
      label.text = "Hanguk Academy - Screen Recording Blocked"
      label.textColor = .white
      label.translatesAutoresizingMaskIntoConstraints = false
      blurEffectView?.contentView.addSubview(label)
      
      NSLayoutConstraint.activate([
        label.centerXAnchor.constraint(equalTo: blurEffectView!.contentView.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: blurEffectView!.contentView.centerYAnchor)
      ])
      
      window.addSubview(blurEffectView!)
    }
  }

  @objc func removeBlur() {
    blurEffectView?.removeFromSuperview()
    blurEffectView = nil
  }
}
