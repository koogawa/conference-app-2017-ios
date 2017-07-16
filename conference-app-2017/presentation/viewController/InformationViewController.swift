import UIKit
import AVFoundation
import QRCodeReader

final class InformationViewController: UITableViewController {
    let readerViewController: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        return QRCodeReaderViewController(builder: builder)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        readerViewController.delegate = self
    }
}

extension InformationViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        if identifier == "\(SponsorViewController.className)Segue" {
            let viewController = segue.destination as! SponsorViewController
            viewController.sponsors = DummyData.shared.conference.sponsors.groping()
        }
    }
}

extension InformationViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == 0 {
            presentQRCodeReader(animated: true, completion: nil)
        }
    }
}