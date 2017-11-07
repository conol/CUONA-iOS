import UIKit
import CoreNFC

private let CUONA_NFC_TYPENAME_Secure = "conol.jp:cuona"
private let CUONA_NFC_TYPENAME_Legacy = "conol.co.jp:cnfc_bt_manu_data"

let CUONA_MAGIC_1 = 0x63
let CUONA_MAGIC_2 = 0x6f
let CUONA_MAGIC_3 = 0x04
let CUONA_MAGIC_3_Legacy = 0x01

private let CUONA_Legacy_SCAN_SIGNATURE_LENGTH = 10
private let CUONA_Legacy_SCAN_SIGNATURE_PREFIX_LENGTH = 3

protocol NFCReaderDelegate: class {
    func nfcReaderGotRecord(_ record: String)
    func nfcReaderFoundCUONARecord(scanSignature: Data?, deviceId: Data,
                                   jsonData: Data)
    func nfcReaderDone()
    func nfcReaderError(_ error: Error)
}

func expandNDEFURI(_ src: Data) -> String {
    if src.count == 0 {
        return ""
    }
    let abbrev: String
    switch src[0] {
    case 0: abbrev = ""
    case 1: abbrev = "http://www."
    case 2: abbrev = "https://www."
    case 3: abbrev = "http://"
    case 4: abbrev = "https://"
    case 5: abbrev = "tel:"
    case 6: abbrev = "mailto:"
    case 7: abbrev = "ftp://anonymous:anonymous@"
    case 8: abbrev = "ftp://ftp."
    case 9: abbrev = "ftps://"
    case 10: abbrev = "sftp://"
    case 11: abbrev = "smb://"
    case 12: abbrev = "nfs://"
    case 13: abbrev = "ftp://"
    case 14: abbrev = "dav://"
    case 15: abbrev = "news:"
    case 16: abbrev = "telnet://"
    case 17: abbrev = "imap:"
    case 18: abbrev = "rtsp://"
    case 19: abbrev = "urn:"
    case 20: abbrev = "pop:"
    case 21: abbrev = "sip:"
    case 22: abbrev = "sips:"
    case 23: abbrev = "tftp:"
    case 24: abbrev = "btspp://"
    case 25: abbrev = "btl2cap://"
    case 26: abbrev = "btgoep://"
    case 27: abbrev = "tcpobex://"
    case 28: abbrev = "irdaobex://"
    case 29: abbrev = "file://"
    case 30: abbrev = "urn:epc:id:"
    case 31: abbrev = "urn:epc:tag:"
    case 32: abbrev = "urn:epc:pat:"
    case 33: abbrev = "urn:epc:raw:"
    case 34: abbrev = "urn:epc:"
    case 35: abbrev = "urn:nfc:"
    default: abbrev = ""
    }
    return abbrev + (String(data: src.dropFirst(), encoding: .utf8) ?? "")
}

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    
    var session: NFCNDEFReaderSession?
    var delegate: NFCReaderDelegate?
    
    required init(delegate: NFCReaderDelegate) {
        self.delegate = delegate
        super.init()
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: DispatchQueue.main,
                                       invalidateAfterFirstRead: true)
        CUONADebugPrint("NFC: started")
    }
    
    func scan(_ message: String?) {
        if message != nil {
            session?.alertMessage = message!
        }
        session?.begin()
    }
    
    private func handleLegacyNDEF(_ payload: Data) {
        if payload.count <= 3 ||
            payload[0] != CUONA_MAGIC_1 ||
            payload[1] != CUONA_MAGIC_2 {
            return;
        }
        let scanSignature = payload.prefix(
            upTo: CUONA_Legacy_SCAN_SIGNATURE_LENGTH)
        let deviceId  = scanSignature.suffix(
            from: CUONA_Legacy_SCAN_SIGNATURE_PREFIX_LENGTH)
        let jsonData = payload.suffix(
            from: CUONA_Legacy_SCAN_SIGNATURE_LENGTH)
        delegate?.nfcReaderFoundCUONARecord(scanSignature: scanSignature,
                                            deviceId: deviceId,
                                            jsonData: jsonData)
    }
    
    private func handleSecureNDEF(_ payload: Data) {
        guard let decryptor = CUONADecryptor(payload: payload) else {
            return
        }
        guard let jsonData = decryptor.decrypt() else {
            return
        }
        let deviceId = Data(decryptor.deviceId)
        delegate?.nfcReaderFoundCUONARecord(scanSignature: nil,
                                            deviceId: deviceId,
                                            jsonData: jsonData)
    }
    
    // NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession,
                       didInvalidateWithError error: Error) {
        if let error = error as? NFCReaderError {
            if error.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
                delegate?.nfcReaderDone()
                return;
            }
        }
        delegate?.nfcReaderError(error)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession,
                       didDetectNDEFs messages: [NFCNDEFMessage]) {
        CUONADebugPrint("NFC: didDetectNDEFs: " + String(describing: messages))
        for message in messages {
            for record in message.records {
                if record.typeNameFormat == .nfcWellKnown &&
                    record.type[0] == 0x55 { // 'U'
                    delegate?.nfcReaderGotRecord(
                        "URI=" + expandNDEFURI(record.payload))
                } else if record.typeNameFormat == .nfcExternal {
                    let typeName = String(data: record.type, encoding: .utf8)
                    ?? "?"
                    let payload = record.payload
                    let s = "type=\(typeName) payload=\(record.payload)"
                    CUONADebugPrint(s)
                    delegate?.nfcReaderGotRecord(s)
                    if typeName == CUONA_NFC_TYPENAME_Legacy {
                        handleLegacyNDEF(payload)
                    } else if typeName == CUONA_NFC_TYPENAME_Secure {
                        handleSecureNDEF(payload)
                    }
                } else {
                    delegate?.nfcReaderGotRecord(String(describing: record))
                }
            }
        }
    }
    
}
