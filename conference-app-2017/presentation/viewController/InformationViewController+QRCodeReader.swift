import UIKit
import AVFoundation
import QRCodeReader

extension InformationViewController {
    func presentQRCodeReader(animated: Bool, completion: (() -> Void)?) {
        guard checkScanPermissions() else { return }
        present(readerViewController, animated: animated, completion: completion)
    }

    fileprivate func presentOpenURLDialog(url: URL) {
        let alert = UIAlertController(title: "Result", message: url.absoluteString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { [weak self] _ in
            self?.presentSafariViewController(url: url, animated: true) })
        )
        present(alert, animated: true, completion: nil)
    }

    private func openSettingApp() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        } else {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }
    }

    private func checkScanPermissions() -> Bool {
        do {
            return try QRCodeReader.supportsMetadataObjectTypes()
        } catch let error as NSError {
            log.error("error: \(error.localizedDescription)")
            var alert = Alert.Builder().set(title: "Error")
            switch error.code {
            case -11852:
                let action = UIAlertAction(title: "Setting", style: .default, handler: { _ in
                    DispatchQueue.main.async {
                        self.openSettingApp()
                    }
                })
                alert = alert
                    .set(message: error.localizedDescription)
                    .set(action: action)
                    .set(action: UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            case -11814:
                alert = alert
                    .set(message: error.localizedDescription)
                    .set(action: UIAlertAction(title: "OK", style: .cancel, handler: nil))
            default:
                alert = alert
                    .set(message: error.localizedDescription)
                    .set(action: UIAlertAction(title: "OK", style: .cancel, handler: nil))
            }
            alert.present(animated: true, completion: nil)
            return false
        }
    }
}

// MARK: - QRCodeReaderViewControllerDelegate
extension InformationViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: false) { [weak self] in
            guard let url = URL(string: result.value) else { return }
            self?.presentOpenURLDialog(url: url)
        }
    }

    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            log.debug("Switching capturing to: \(cameraName)")
        }
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
