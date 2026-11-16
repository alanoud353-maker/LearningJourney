







import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var goals: [LearningGoal]
    
    var body: some View {
        
        NavigationStack {
            

            if goals.isEmpty {
                OnboardingView()
            } else {
                Logday()
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}


