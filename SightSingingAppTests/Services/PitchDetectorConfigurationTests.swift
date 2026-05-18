import XCTest
@testable import SightSingingApp

/// PitchDetector 配置的单元测试
final class PitchDetectorConfigurationTests: XCTestCase {
    
    func testFFTSizeIsPowerOfTwo() {
        // FFT 大小应该是 2 的幂
        let fftSize = PitchDetectorConfiguration.fftSize
        XCTAssertEqual(fftSize & (fftSize - 1), 0, "FFT 大小应该是 2 的幂")
    }
    
    func testMinFrequencyIsReasonable() {
        // 最小检测频率应大于 20Hz（人耳听力下限）
        XCTAssertGreaterThan(PitchDetectorConfiguration.minFrequency, 20)
        // 但应小于吉他最低音 E2 (82.41Hz)
        XCTAssertLessThan(PitchDetectorConfiguration.minFrequency, 82)
    }
    
    func testMaxFrequencyIsReasonable() {
        // 最大检测频率应小于人耳上限 20kHz
        XCTAssertLessThan(PitchDetectorConfiguration.maxFrequency, 20000)
        // 但应大于吉他最高音 (约 800Hz)
        XCTAssertGreaterThan(PitchDetectorConfiguration.maxFrequency, 1000)
    }
    
    func testConfidenceThresholdIsValid() {
        // 置信度应在 0-1 之间
        XCTAssertGreaterThanOrEqual(PitchDetectorConfiguration.confidenceThreshold, 0)
        XCTAssertLessThanOrEqual(PitchDetectorConfiguration.confidenceThreshold, 1)
    }
}
