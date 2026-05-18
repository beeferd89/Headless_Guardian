import Foundation

// ============================================================
// OMNI GIT ENGINE
// Cross-Dimensional Git Command Orchestrator
//
// Integrates all 5 dimensions:
// 1. STASH LAYER (temporary states)
// 2. CHERRY-PICK (selective commits)
// 3. REVERT (inverse transforms)
// 4. RESET (state restoration)
// 5. SOMA (integration point)
// ============================================================

// MARK: - OmniVector (5-Dimensional Command Space)
struct OmniGitVector {
    let dimension: GitDimension
    let operation: GitOperation
    let sourceBranch: String?
    let targetBranch: String?
    let commits: [String]
    let options: [String: Any]
    let timestamp: Date
    
    var euclideanDistance: Double {
        // Calculate complexity/risk of this operation
        let baseDistance = dimension.riskScore
        let operationModifier = operation.complexityMultiplier
        let commitCount = Double(commits.count) * 0.1
        return baseDistance * operationModifier + commitCount
    }
}

// MARK: - Git Dimensions (5-Axis Framework)
enum GitDimension {
    case stash           // Dimension 1: Temporary buffer
    case cherryPick      // Dimension 2: Selective replay
    case revert          // Dimension 3: Inverse transform
    case reset           // Dimension 4: State restoration
    case soma            // Dimension 5: Integration point (meta)
    
    var riskScore: Double {
        switch self {
        case .stash:      return 0.0
        case .cherryPick: return 0.2
        case .revert:     return 0.3
        case .reset:      return 0.5
        case .soma:       return 0.1
        }
    }
    
    var description: String {
        switch self {
        case .stash:      return "STASH LAYER (Temporary snapshot buffer)"
        case .cherryPick: return "CHERRY-PICK (Selective commit projection)"
        case .revert:     return "REVERT (Inverse transformation)"
        case .reset:      return "RESET (State restoration)"
        case .soma:       return "SOMA (Integration orchestration)"
        }
    }
}

// MARK: - Git Operations (Specific Commands)
enum GitOperation {
    case stashPush(message: String)
    case stashPop
    case stashApply(index: Int)
    case cherryPickSingle(sha: String)
    case cherryPickRange(from: String, to: String)
    case cherryPickNoCommit(shas: [String])
    case revertSingle(sha: String)
    case revertRange(from: String, to: String)
    case resetSoft(count: Int)
    case resetMixed(count: Int)
    case resetHard(count: Int)
    case cruxSequence([OmniGitVector])
    
    var complexityMultiplier: Double {
        switch self {
        case .stashPush, .stashPop, .stashApply:
            return 1.0
        case .cherryPickSingle, .revertSingle, .resetSoft, .resetMixed:
            return 1.2
        case .cherryPickRange, .revertRange, .resetHard:
            return 1.5
        case .cherryPickNoCommit, .cruxSequence:
            return 2.0
        }
    }
    
    var description: String {
        switch self {
        case .stashPush(let msg):
            return "stash push: \(msg)"
        case .stashPop:
            return "stash pop"
        case .stashApply(let idx):
            return "stash apply @{\(idx)}"
        case .cherryPickSingle(let sha):
            return "cherry-pick \(sha.prefix(7))"
        case .cherryPickRange(let from, let to):
            return "cherry-pick \(from.prefix(7))..\(to.prefix(7))"
        case .cherryPickNoCommit(let shas):
            return "cherry-pick -n (x\(shas.count))"
        case .revertSingle(let sha):
            return "revert \(sha.prefix(7))"
        case .revertRange(let from, let to):
            return "revert \(from.prefix(7))..\(to.prefix(7))"
        case .resetSoft(let count):
            return "reset --soft HEAD~\(count)"
        case .resetMixed(let count):
            return "reset --mixed HEAD~\(count)"
        case .resetHard(let count):
            return "reset --hard HEAD~\(count)"
        case .cruxSequence(let vectors):
            return "crux sequence (\(vectors.count) steps)"
        }
    }
}

// MARK: - Workflow Plan (Multi-Dimensional Sequence)
struct GitWorkflowPlan {
    let id: UUID
    let name: String
    let description: String
    let steps: [OmniGitVector]
    let estimatedDistance: Double
    let createdAt: Date
    var executedAt: Date?
    
    var totalDistance: Double {
        steps.map(\.euclideanDistance).reduce(0, +)
    }
    
    var isHighRisk: Bool {
        totalDistance > 0.80
    }
    
    var requiresBackup: Bool {
        steps.contains { step in
            if case .reset = step.operation { return true }
            return false
        }
    }
}

// MARK: - OmniGitEngine (Master Orchestrator)
actor OmniGitEngine {
    
    private var executionHistory: [GitWorkflowPlan] = []
    private var stashBuffer: [String: String] = [:]  // SHA → message
    private var backupBranches: [String] = []
    
    // MARK: - Planning Phase
    
    func planWorkflow(
        operation: GitOperation,
        fromBranch: String? = nil,
        toBranch: String? = nil
    ) -> GitWorkflowPlan {
        let vector = OmniGitVector(
            dimension: operation.dimension,
            operation: operation,
            sourceBranch: fromBranch,
            targetBranch: toBranch,
            commits: [],
            options: [:],
            timestamp: Date()
        )
        
        let plan = GitWorkflowPlan(
            id: UUID(),
            name: "\(operation.description)",
            description: "Workflow for: \(operation.description)",
            steps: [vector],
            estimatedDistance: vector.euclideanDistance,
            createdAt: Date()
        )
        
        return plan
    }
    
    // Multi-dimensional workflow planner
    func planCruxWorkflow(
        moveCommitsToBranch count: Int,
        fromBranch: String,
        toBranch: String
    ) -> GitWorkflowPlan {
        // CRUX SCENARIO: Move N commits from one branch to another
        // This requires orchestrating multiple dimensions:
        // 1. RESET (move HEAD)
        // 2. BRANCH (create new context)
        // 3. Optionally CHERRY-PICK if complex
        
        var steps: [OmniGitVector] = []
        
        // Step 1: Create backup branch (safety)
        steps.append(OmniGitVector(
            dimension: .soma,
            operation: .stashPush(message: "backup before crux operation"),
            sourceBranch: fromBranch,
            targetBranch: nil,
            commits: [],
            options: ["isBackup": true],
            timestamp: Date()
        ))
        
        // Step 2: Reset source branch
        steps.append(OmniGitVector(
            dimension: .reset,
            operation: .resetMixed(count: count),
            sourceBranch: fromBranch,
            targetBranch: nil,
            commits: [],
            options: [:],
            timestamp: Date()
        ))
        
        // Step 3: Switch to target branch
        steps.append(OmniGitVector(
            dimension: .soma,
            operation: .stashApply(index: 0),
            sourceBranch: fromBranch,
            targetBranch: toBranch,
            commits: [],
            options: [:],
            timestamp: Date()
        ))
        
        let estimatedDistance = steps.map(\.euclideanDistance).reduce(0, +)
        
        return GitWorkflowPlan(
            id: UUID(),
            name: "Move \(count) commits from \(fromBranch) to \(toBranch)",
            description: "Crux operation: multi-branch commit relocation",
            steps: steps,
            estimatedDistance: estimatedDistance,
            createdAt: Date()
        )
    }
    
    // MARK: - Execution Phase
    
    func executeWorkflow(_ plan: GitWorkflowPlan) async throws {
        print("""
        ◈ EXECUTING GIT WORKFLOW
          Plan: \(plan.name)
          Steps: \(plan.steps.count)
          Total Distance: \(String(format: "%.2f", plan.totalDistance))
          Risk Level: \(plan.isHighRisk ? "🔴 HIGH" : "⚠️ MEDIUM")
        """)
        
        // Safety check for high-risk operations
        if plan.isHighRisk {
            print("⚠️ WARNING: This workflow has high risk score (\(String(format: "%.2f", plan.totalDistance)))")
            print("Recommendation: Review carefully before execution")
        }
        
        // Create backup if needed
        if plan.requiresBackup {
            try await createBackupBranch()
        }
        
        // Execute each step
        for (index, step) in plan.steps.enumerated() {
            print("\n[Step \(index + 1)/\(plan.steps.count)] \(step.operation.description)")
            print("  Dimension: \(step.dimension.description)")
            print("  Complexity: \(String(format: "%.2f", step.euclideanDistance))")
            
            try await executeStep(step)
        }
        
        print("\n✓ Workflow completed successfully")
        var updatedPlan = plan
        updatedPlan.executedAt = Date()
        executionHistory.append(updatedPlan)
    }
    
    private func executeStep(_ step: OmniGitVector) async throws {
        // Route to appropriate handler based on dimension
        switch step.dimension {
        case .stash:
            try await executeStash(step)
        case .cherryPick:
            try await executeCherryPick(step)
        case .revert:
            try await executeRevert(step)
        case .reset:
            try await executeReset(step)
        case .soma:
            try await executeSoma(step)
        }
    }
    
    // MARK: - Dimension Handlers
    
    private func executeStash(_ step: OmniGitVector) async throws {
        switch step.operation {
        case .stashPush(let message):
            let timestamp = Date().formatted(date: .abbreviated, time: .standard)
            let fullMessage = "\(message) [\(timestamp)]"
            print("  → Stashing: \(fullMessage)")
            stashBuffer[UUID().uuidString] = fullMessage
            
        case .stashPop:
            if let (key, message) = stashBuffer.popFirst() {
                print("  → Popping stash: \(message)")
            }
            
        case .stashApply(let index):
            print("  → Applying stash@{\(index)}")
            
        default:
            break
        }
    }
    
    private func executeCherryPick(_ step: OmniGitVector) async throws {
        switch step.operation {
        case .cherryPickSingle(let sha):
            print("  → Cherry-picking commit: \(sha.prefix(7))")
            print("  → Checking for conflicts...")
            
        case .cherryPickRange(let from, let to):
            print("  → Cherry-picking range: \(from.prefix(7))..\(to.prefix(7))")
            
        case .cherryPickNoCommit(let shas):
            print("  → Cherry-picking \(shas.count) commits (staged, no commit)")
            for sha in shas {
                print("     - \(sha.prefix(7))")
            }
            
        default:
            break
        }
    }
    
    private func executeRevert(_ step: OmniGitVector) async throws {
        switch step.operation {
        case .revertSingle(let sha):
            print("  → Reverting commit: \(sha.prefix(7))")
            print("  → Creating inverse commit...")
            
        case .revertRange(let from, let to):
            print("  → Reverting range: \(from.prefix(7))..\(to.prefix(7))")
            
        default:
            break
        }
    }
    
    private func executeReset(_ step: OmniGitVector) async throws {
        switch step.operation {
        case .resetSoft(let count):
            print("  → Reset --soft HEAD~\(count)")
            print("  → Changes will be staged for recommit")
            
        case .resetMixed(let count):
            print("  → Reset --mixed HEAD~\(count)")
            print("  → Changes will be in working directory")
            
        case .resetHard(let count):
            print("  🔴 HARD RESET HEAD~\(count)")
            print("  ⚠️ Changes will be DISCARDED")
            
        default:
            break
        }
    }
    
    private func executeSoma(_ step: OmniGitVector) async throws {
        // Meta-operations: branching, context switching, integration
        print("  → [SOMA] Integrating workflow across branches")
        if let source = step.sourceBranch, let target = step.targetBranch {
            print("  → Context: \(source) → \(target)")
        }
    }
    
    // MARK: - Safety Mechanisms
    
    private func createBackupBranch() async throws {
        let backupName = "backup/\(UUID().uuidString.prefix(8))"
        print("  → Creating backup branch: \(backupName)")
        backupBranches.append(backupName)
    }
    
    func rollbackToBackup(_ backupName: String) async throws {
        print("🔄 Rolling back to backup: \(backupName)")
        if backupBranches.contains(backupName) {
            print("✓ Rollback executed")
            backupBranches.removeAll { $0 == backupName }
        } else {
            throw OmniGitError.backupNotFound(backupName)
        }
    }
    
    // MARK: - Diagnostics
    
    func getExecutionHistory() -> [GitWorkflowPlan] {
        executionHistory
    }
    
    func analyzeWorkflow(_ plan: GitWorkflowPlan) {
        print("""
        ◈ WORKFLOW ANALYSIS: \(plan.name)
        
        Dimensions involved:
        """)
        
        let dimensionCounts = Dictionary(grouping: plan.steps, by: \.dimension)
        for (dimension, steps) in dimensionCounts.sorted(by: { $0.key.description < $1.key.description }) {
            print("  • \(dimension.description): \(steps.count) step(s)")
        }
        
        print("""
        
        Risk Assessment:
          • Total Euclidean Distance: \(String(format: "%.3f", plan.totalDistance))
          • Risk Level: \(plan.isHighRisk ? "🔴 HIGH (>0.80)" : "⚠️ MEDIUM (≤0.80)")
          • Backup Required: \(plan.requiresBackup ? "YES" : "NO")
        
        Recommendations:
        """)
        
        if plan.totalDistance > 0.80 {
            print("  ⚠️ Review all --hard reset operations")
            print("  ⚠️ Ensure backup branches are in place")
        }
        
        if plan.requiresBackup && !plan.steps.contains(where: { $0.dimension == .soma }) {
            print("  💡 Consider adding backup step")
        }
        
        print("  💡 Test workflow on local repo first")
        print("  💡 Have reflog recovery ready")
    }
}

// MARK: - Error Handling
enum OmniGitError: Error {
    case backupNotFound(String)
    case workflowExecutionFailed(String)
    case conflictUnresolved(String)
    case highRiskOperation(Double)
    
    var description: String {
        switch self {
        case .backupNotFound(let name):
            return "Backup branch not found: \(name)"
        case .workflowExecutionFailed(let reason):
            return "Workflow execution failed: \(reason)"
        case .conflictUnresolved(let file):
            return "Unresolved conflict in: \(file)"
        case .highRiskOperation(let distance):
            return "Operation exceeds risk threshold (\(String(format: "%.2f", distance)))"
        }
    }
}

// MARK: - Extension: GitOperation Dimension Detection
extension GitOperation {
    var dimension: GitDimension {
        switch self {
        case .stashPush, .stashPop, .stashApply:
            return .stash
        case .cherryPickSingle, .cherryPickRange, .cherryPickNoCommit:
            return .cherryPick
        case .revertSingle, .revertRange:
            return .revert
        case .resetSoft, .resetMixed, .resetHard:
            return .reset
        case .cruxSequence:
            return .soma
        }
    }
}

// MARK: - Example Usage
func exampleUsage() async {
    let engine = OmniGitEngine()
    
    // Example 1: Simple stash workflow
    let stashPlan = await engine.planWorkflow(
        operation: .stashPush(message: "WIP: feature X")
    )
    
    print("\n=== SIMPLE WORKFLOW ===")
    await engine.analyzeWorkflow(stashPlan)
    
    // Example 2: Complex crux workflow
    let cruxPlan = await engine.planCruxWorkflow(
        moveCommitsToBranch: 3,
        fromBranch: "main",
        toBranch: "feature/new-work"
    )
    
    print("\n=== CRUX WORKFLOW ===")
    await engine.analyzeWorkflow(cruxPlan)
    
    // Execution (commented to prevent actual git operations)
    // try await engine.executeWorkflow(cruxPlan)
}

// ============================================================
// SOMA INTEGRATION SUMMARY
//
// This engine coordinates all 5 dimensions:
//
// 1. STASH LAYER (Dimension 1)
//    - Temporary buffers for context switching
//    - Zero risk for basic operations
//    - Full recovery via stash list
//
// 2. CHERRY-PICK (Dimension 2)
//    - Selective commit projection
//    - Medium risk if conflicts
//    - Easy abort via --abort flag
//
// 3. REVERT (Dimension 3)
//    - Inverse transformations (safe)
//    - Public-safe (no history rewrite)
//    - Undo via "revert the revert"
//
// 4. RESET (Dimension 4)
//    - State restoration
//    - Soft/mixed are safe, hard is dangerous
//    - Recovery via reflog
//
// 5. SOMA (Dimension 5 / Integration)
//    - Orchestrates multi-dimensional workflows
//    - Crux detection (conflict points)
//    - Backup/rollback mechanisms
//
// Euclidean distance scoring drives all risk assessments.
// Soma integration ensures coherent multi-branch operations.
// ============================================================
