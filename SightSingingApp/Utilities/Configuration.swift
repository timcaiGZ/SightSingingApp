import Foundation

/// 应用级常量
enum AppConstants {
    /// 应用名称
    static let appName = "吉他视唱练耳"

    /// 测试名称
    static let testName = "综合能力诊断"

    /// 测试描述
    static let testDescription = "测试将覆盖 6 大核心技能"

    /// 应用版本号
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// 构建号
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

/// 音频引擎配置常量
enum AudioConfiguration {
    /// 采样率
    static let sampleRate: Double = 44100.0
    
    /// 默认音符持续时间（秒）
    static let defaultDuration: TimeInterval = 0.8
    
    /// 默认和弦持续时间（秒）
    static let defaultChordDuration: TimeInterval = 1.0
    
    /// 吉他音色谐波配置
    static let guitarHarmonics: [(partial: Int, amplitude: Double)] = [
        (1, 1.0),   // 基频
        (2, 0.5),   // 2次谐波
        (3, 0.3),   // 3次谐波
        (4, 0.15),  // 4次谐波
        (5, 0.1),   // 5次谐波
        (6, 0.05),  // 6次谐波
    ]
    
    /// ADSR 包络参数
    enum ADSR {
        static let attackTime: Double = 0.02   // 起音时间比例
        static let decayTime: Double = 0.08    // 衰减时间比例
        static let sustainLevel: Double = 0.6  // 持续音量
        static let releaseTime: Double = 0.2   // 释放时间比例
        static let releaseStartRatio: Double = 0.8  // 释放开始时音量比例
    }
    
    /// 输出音量上限
    static let maxOutputAmplitude: Double = 0.7
}

/// 测试引擎配置常量
enum TestConfiguration {
    /// 诊断测试题目总数
    static let diagnosticTestQuestionCount = 30
    
    /// 每个维度题目数
    static let questionsPerDimension = 5
    
    /// 正确率权重
    static let accuracyWeight: Double = 0.7
    
    /// 反应速度权重
    static let reactionTimeWeight: Double = 0.3
    
    /// 快速反应阈值（秒）
    static let fastReactionThreshold: Double = 2.0
    
    /// 中等反应阈值（秒）
    static let mediumReactionThreshold: Double = 5.0
    
    /// 和弦推荐权重倍数
    static let chordRecommendationMultiplier: Double = 1.3
    
    /// 及格分数
    static let passingScore: Int = 60
    
    /// 优秀分数
    static let excellentScore: Int = 90
}

/// 视唱练习配置常量
enum SingingConfiguration {
    /// 音准评分阈值（音分）
    enum PitchThreshold {
        static let perfect: Double = 10.0       // 满分阈值
        static let good: Double = 30.0          // 良好阈值
        static let acceptable: Double = 50.0   // 可接受阈值
    }
    
    /// 音准评分权重
    static let pitchScoreWeight: Double = 0.7
    
    /// 节奏评分权重
    static let rhythmScoreWeight: Double = 0.3
    
    /// 音高检测更新间隔（秒）
    static let detectionUpdateInterval: TimeInterval = 0.1
}

/// 音高检测配置常量
enum PitchDetectorConfiguration {
    /// FFT 大小
    static let fftSize: Int = 4096
    
    /// 最小检测频率（Hz）
    static let minFrequency: Double = 60.0
    
    /// 最大检测频率（Hz）
    static let maxFrequency: Double = 2000.0
    
    /// 置信度阈值
    static let confidenceThreshold: Double = 0.8
}
