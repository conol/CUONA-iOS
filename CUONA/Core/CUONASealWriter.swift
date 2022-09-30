import Foundation
import CoreNFC

public protocol CUONASealWriterDelegate: class {

    // Seal detection
    func cuonaSealReadyForWrite(deviceId: String) -> Bool

}

public func createCUONASealWriter(delegate: CUONASealWriterDelegate)
    -> CUONASealWriter? {
    if #available(iOS 13, *) {
        return CUONASealWriterImpl(delegate: delegate)
    } else {
        return nil
    }
}

// Base class for iOS version < 13
public class CUONASealWriter: NSObject {
    
    public var jsonWriteData: String? = nil
    public var urlWriteData: String? = nil
    public var wifiConfigData: NFCWifiConfig? = nil
    
    public var doPermanentLock: Bool = false

    func scan() -> Bool {
        return false
    }

}

@available(iOS 13,*)
class CUONASealWriterImpl: CUONASealWriter, NFCTagReaderSessionDelegate {
    
    let delegate: CUONASealWriterDelegate
    
    required init(delegate: CUONASealWriterDelegate) {
        self.delegate = delegate
    }

    override func scan() -> Bool {
        guard NFCReaderSession.readingAvailable else {
            CUONADebugPrint("NFC reading not available")
            return false
        }
        CUONADebugPrint("NFC reading available")

        let session = NFCTagReaderSession(pollingOption: .iso14443,
                                      delegate: self)
        session?.begin()
        return true
    }
    
    func handleMifareUltralight(_ session: NFCTagReaderSession,
                                mifare: NFCMiFareTag) {

        mifare.readNDEF { (message, error) in
            let deviceId = self.getDeviceIdFromCuonaNDEF(message: message)
                ??  self.getDeviceIdFromMifareIdentifier(mifare: mifare)
            let devIdString = deviceId.map {
                String(format: "%02hhx", $0) }.joined().split(2)
            if !self.delegate.cuonaSealReadyForWrite(deviceId: devIdString) {
                // No write action
                session.invalidate()
                return
            }
            
            let ndefMessage = self.buildNDEFMessage(deviceId: deviceId)
            mifare.writeNDEF(ndefMessage) { (error) in
                if error != nil {
                    CUONADebugPrint("writeNDEF: error: \(error!)")
                    session.invalidate(errorMessage: "error: \(error!)")
                } else {
                    CUONADebugPrint("writeNDEF success")
                    
                    if self.doPermanentLock {
                        mifare.writeLock(completionHandler: { (error) in
                            if let error = error {
                                CUONADebugPrint("writeLock: error \(error)")
                                session.invalidate(errorMessage: "Lock failed!")
                            } else {
                                CUONADebugPrint("writeLock: success")
                                session.invalidate()
                            }
                        })
                    } else {
                        session.invalidate()
                    }
                }
            }
        }
    }
    
    private func getDeviceIdFromMifareIdentifier(mifare: NFCMiFareTag) -> [UInt8] {
        CUONADebugPrint("getting device id from Mifare identifier")
        let id = mifare.identifier
        if id.count == 7 {
            // Add check codes
            // cf. ISO/IEC 1444-3:2001 6.4.4. "UID contents and cascade levels"
//            let bcc0 = 0x88 ^ id[0] ^ id[1] ^ id[2]
//            let bcc1 = id[3] ^ id[4] ^ id[5] ^ id[6]
//            return [id[0], id[1], id[2], bcc0,
//                    id[3], id[4], id[5], id[6], bcc1]
            return [id[0], id[1], id[2], id[3], id[4], id[5], id[6]]
        } else {
            return Array(id)
        }
    }
    
    private func getDeviceIdFromCuonaNDEF(message: NFCNDEFMessage?) -> [UInt8]? {
        guard let message = message else {
            return nil
        }
        for record in message.records {
            if record.typeNameFormat == .nfcExternal {
                let typeName = String(data: record.type, encoding: .utf8)
                    ?? "?"
                let payload = record.payload
                if typeName == CUONA_NFC_TYPENAME_Secure {
                    if let decryptor = CUONADecryptor(payload: payload) {
                        CUONADebugPrint("got device id from NDEF")
                        return decryptor.deviceId
                    }
                }
            }
        }
        return nil
    }
    
    private func buildNDEFMessage(deviceId: [UInt8]) -> NFCNDEFMessage {
        var ndefPayloads = [NFCNDEFPayload]()

        if let jsonStr = jsonWriteData {
            if let jsonData = jsonStr.data(using: .utf8) {
                let enc = CUONAEncryptor(deviceId: Data(deviceId))
                if let payload = enc.encrypt(jsonData: jsonData) {
                    let type = CUONA_NFC_TYPENAME_Secure.data(using: .utf8)!
                    let ndef = NFCNDEFPayload(format: .nfcExternal, type: type,
                                              identifier: Data(), payload: payload)
                    ndefPayloads.append(ndef)
                } else {
                    CUONADebugPrint("CUONAEncryptor.encode failed")
                }
            } else {
                CUONADebugPrint("getting Data from JSON failed")
            }
        }
        
        if let urlStr = urlWriteData {
            if let ndef = NFCNDEFPayload.wellKnownTypeURIPayload(string: urlStr) {
                ndefPayloads.append(ndef)
            } else {
                CUONADebugPrint("NFCNDEFPayload.wellKnownTypeURIPayload failed")
            }
        }
        
        if let wifi = wifiConfigData {
            if let ndef = wifi.createNdef() {
                ndefPayloads.append(ndef)
            } else {
                CUONADebugPrint("NFCWifiConfig.createNdef failed")
            }
        }
        
        return NFCNDEFMessage(records: ndefPayloads)
    }
    
    // NFCTagReaderSessionDelegate
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        CUONADebugPrint("tagReaderSessionDidBecomeActive")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession,
                          didDetect tags: [NFCTag]) {
        CUONADebugPrint("tagReaderSession: didDetect: \(tags)")

        var tag: NFCTag? = nil
        for nfcTag in tags {
            if case let .miFare(mifareTag) = nfcTag {
                if mifareTag.mifareFamily == .ultralight {
                    tag = nfcTag
                    break
                }
            }
        }
        
        if tag == nil {
            CUONADebugPrint("Tag is not MiFare Ultralight")
            session.invalidate(errorMessage: "Tag is not MiFare Ultralight.")
            return
        }

        session.connect(to: tag!) { (error) in
            if error != nil {
                CUONADebugPrint("connect error: \(error!)")
                session.invalidate(errorMessage: "Connect error")
                return
            }
            if case .miFare(let mifareTag) = tag  {
                self.handleMifareUltralight(session, mifare: mifareTag)
            } else {
                session.invalidate()
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession,
                          didInvalidateWithError error: Error) {
        CUONADebugPrint("tagReaderSession: didInvalidateWithError: \(error)")
    }
    
}
