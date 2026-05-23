import XCTest
@testable import SightSingingApp

/// MusicTheory 工具类的单元测试
final class MusicTheoryTests: XCTestCase {
    
    // MARK: - 音高转换测试
    
    func testFrequencyFromMIDIReturnsCorrectValue() {
        // A4 (MIDI 69) 应该等于 440Hz
        let frequency = MusicTheory.frequencyFromMIDI(69)
        XCTAssertEqual(frequency, 440.0, accuracy: 0.001)
    }
    
    func testFrequencyFromMIDIForOctaveUp() {
        // A5 (MIDI 81) 应该是 A4 的两倍
        let frequencyA5 = MusicTheory.frequencyFromMIDI(81)
        let frequencyA4 = MusicTheory.frequencyFromMIDI(69)
        XCTAssertEqual(frequencyA5, frequencyA4 * 2, accuracy: 0.001)
    }
    
    func testMIDINoteFromSolfegeReturnsCorrectValue() {
        // C4 (数字 1) 应该返回 MIDI 60
        XCTAssertEqual(MusicTheory.midiNote(from: "1", octave: 4), 60)
        // G4 (数字 5) 应该返回 MIDI 67
        XCTAssertEqual(MusicTheory.midiNote(from: "5", octave: 4), 67)
    }
    
    func testMIDINoteFromSolfegeReturnsNilForInvalidInput() {
        // 无效输入应返回 nil
        XCTAssertNil(MusicTheory.midiNote(from: "0", octave: 4)) // 0 不是有效简谱
        XCTAssertNil(MusicTheory.midiNote(from: "8", octave: 4)) // 8 不是有效简谱
        XCTAssertNil(MusicTheory.midiNote(from: "X", octave: 4)) // 非数字输入
    }
    
    func testMIDINoteFromSolfegeWithDifferentOctaves() {
        // 同一简谱在不同八度应相差 12
        let midiC4 = MusicTheory.midiNote(from: "1", octave: 4)
        let midiC5 = MusicTheory.midiNote(from: "1", octave: 5)
        XCTAssertEqual(midiC5! - midiC4!, 12)
    }
    
    // MARK: - 音分计算测试
    
    func testCentsBetweenSameNoteIsZero() {
        let cents = MusicTheory.centsBetween(60, 60)
        XCTAssertEqual(cents, 0.0, accuracy: 0.001)
    }
    
    func testCentsBetweenOneOctaveIs1200() {
        // 纯八度应该是 1200 音分
        let cents = MusicTheory.centsBetween(60, 72) // C4 到 C5
        XCTAssertEqual(cents, 1200.0, accuracy: 0.1)
    }
    
    func testCentsDeviationSymmetric() {
        // 偏差应该大致对称（对数特性导致微小差异）
        let higher = MusicTheory.centsDeviation(detected: 445, target: 440)
        let lower = MusicTheory.centsDeviation(detected: 435, target: 440)
        XCTAssertEqual(abs(higher), abs(lower), accuracy: 0.3)
    }
    
    // MARK: - 音准评分测试
    
    func testPitchScorePerfectWhenWithinThreshold() {
        // ±10 音分内应得满分
        XCTAssertEqual(MusicTheory.pitchScore(cents: 0), 100)
        XCTAssertEqual(MusicTheory.pitchScore(cents: 5), 100)
        XCTAssertEqual(MusicTheory.pitchScore(cents: 10), 100)
    }
    
    func testPitchScoreGoodWithinThreshold() {
        // ±10-30 音分应得 70-100 分
        let score20 = MusicTheory.pitchScore(cents: 20)
        XCTAssertGreaterThan(score20, 70)  // 20音分: 100-(20-10)*1.5 = 85 > 70
        XCTAssertLessThanOrEqual(score20, 100)
    }
    
    func testPitchScoreDecreasesWithLargerDeviation() {
        // 偏差越大分数越低
        let score10 = MusicTheory.pitchScore(cents: 10)
        let score30 = MusicTheory.pitchScore(cents: 30)
        let score50 = MusicTheory.pitchScore(cents: 50)
        
        XCTAssertGreaterThan(score30, score50)
        XCTAssertGreaterThan(score10, score30)
    }
    
    func testPitchScoreZeroForLargeDeviation() {
        // 超过阈值应返回 0
        XCTAssertEqual(MusicTheory.pitchScore(cents: 100), 0)
    }
    
    func testPitchScoreSymmetric() {
        // 正负偏差应得相同分数
        XCTAssertEqual(MusicTheory.pitchScore(cents: 20), MusicTheory.pitchScore(cents: -20))
    }
    
    // MARK: - 升降号测试
    
    func testSolfegeWithAccidentalSharp() {
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("1", sharp: true), "1#")
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("4", sharp: true), "4#")
    }
    
    func testSolfegeWithAccidentalFlat() {
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("1", sharp: false), "1♭")
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("5", sharp: false), "5♭")
    }
    
    func testSolfegeWithAccidentalEnum() {
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("1", accidental: .sharp), "1#")
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("1", accidental: .flat), "1♭")
        XCTAssertEqual(MusicTheory.solfegeWithAccidental("1", accidental: .natural), "1")
    }
    
    // MARK: - 吉他定音测试
    
    func testStandardTuningHasSixStrings() {
        XCTAssertEqual(MusicTheory.standardTuning.count, 6)
    }
    
    func testStandardTuningEADGBE() {
        let strings = MusicTheory.standardTuning.map { $0.note }
        XCTAssertEqual(strings, ["E4", "B3", "G3", "D3", "A2", "E2"])
    }
    
    func testStandardTuningFrequenciesArePositive() {
        for string in MusicTheory.standardTuning {
            XCTAssertGreaterThan(string.frequency, 0)
        }
    }
    
    // MARK: - 音程测试
    
    func testIntervalsContainsCommonIntervals() {
        let intervalNames = MusicTheory.intervals.map { $0.name }
        XCTAssertTrue(intervalNames.contains("纯一度"))
        XCTAssertTrue(intervalNames.contains("纯四度"))
        XCTAssertTrue(intervalNames.contains("纯五度"))
        XCTAssertTrue(intervalNames.contains("纯八度"))
    }
    
    func testIntervalsSemitoneCounts() {
        // 纯五度应该是 7 个半音
        if let perfectFifth = MusicTheory.intervals.first(where: { $0.name == "纯五度" }) {
            XCTAssertEqual(perfectFifth.semitones, 7)
        }
        
        // 纯八度应该是 12 个半音
        if let octave = MusicTheory.intervals.first(where: { $0.name == "纯八度" }) {
            XCTAssertEqual(octave.semitones, 12)
        }
    }
}
