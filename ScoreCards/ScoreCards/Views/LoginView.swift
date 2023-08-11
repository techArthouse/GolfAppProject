//
//  LoginView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/27/23.
//

import Foundation


import SwiftUI
import GoogleSignIn


class UserAuthModel: ObservableObject {
    
    @Published var givenName: String = ""
    @Published var profilePicUrl: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
//    @Published var playerId: Int = 0
    
    private let accessTokenKey = "AccessToken"
    private let currentPlayerIdKey = "CurrentPlayerId"
    
    var accessToken: String {
        get {
            UserDefaults.standard.string(forKey: accessTokenKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: accessTokenKey)
        }
    }
    
    var playerId: Int {
        get {
            UserDefaults.standard.integer(forKey: currentPlayerIdKey) ?? -1
        }
        set {
            UserDefaults.standard.set(newValue, forKey: currentPlayerIdKey)
        }
    }
    
    init() {
        check()
    }
    
    func checkStatus() {
        if GIDSignIn.sharedInstance.currentUser != nil {
            let user = GIDSignIn.sharedInstance.currentUser
            guard let user = user else { return }
            let givenName = user.profile?.givenName
            let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
            self.givenName = givenName ?? ""
            self.profilePicUrl = profilePicUrl
            self.isLoggedIn = true
        } else {
            self.isLoggedIn = false
            self.givenName = "Not Logged In"
            self.profilePicUrl = ""
        }
    }
    
    func check() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            return
        }

        let signInConfig = GIDConfiguration(clientID: "66603309185-k7bccilod9b8pqfk87ngdssgv6ep1da8.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            guard error == nil else {
                self?.errorMessage = "error: \(error!.localizedDescription)"
                return
            }

            guard let signInResult = signInResult else {
                self?.errorMessage = "User is nil"
                return
            }
            signInResult.user.refreshTokensIfNeeded { user, error in
                guard error == nil else {
                    self?.errorMessage = "error: \(error!.localizedDescription)"
                    return
                }
                guard let user = user else {
                    self?.errorMessage = "user is nil"
                    return
                 }
                guard let idToken = user.idToken?.tokenString else {
                    self?.errorMessage = "ID token is nil"
                    return
                }
                // Send ID token to the backend server for verification
                self?.sendIDTokenToBackend(idToken, user.accessToken.tokenString) {
                    print("completing brutha")
//                    self?.accessToken = user.accessToken.tokenString
                }
            }
        }
    }

    private func sendIDTokenToBackend(_ idToken: String,_ accessToken: String, completion: @escaping () -> Void) {
        let url = URL(string: "http://localhost:5001/exchange")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params: [String: Any] = ["code": idToken] // Modify the parameter name if needed
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                self.errorMessage = "Failed to send ID token to the server: \(error.localizedDescription)"
                return
            }

            // Handle the response from the backend server
            DispatchQueue.main.async {
                if let data = data {
                    print(String(data: data, encoding: .utf8))
                    do {
                        let response = try JSONDecoder().decode(BackendResponse.self, from: data)
                        if response.error.isEmpty {
                            if let playerID = response.player_id {
                                let contentView = HomeView().environmentObject(UserAuthModel())
                                self.playerId = playerID // Update the playerId
                                self.accessToken = accessToken
                                completion()
                            
                            // Update the userAuth object in the environment
//                            let contentView = HomeView().environmentObject(self)
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: contentView)
                            } else {
                                self.errorMessage = "Player ID is nil"
                            }
                        } else {
                            self.errorMessage = response.error
                        }
                    } catch {
                        self.errorMessage = "Failed to decode the response from the server"
                    }
                }
            }
        }.resume()
    }

    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        self.checkStatus()
        // Clear the stored access token
        self.accessToken = ""
        self.playerId = -1
        
        // Reset the app's root view controller to the LoginView
        let loginView = LoginView().environmentObject(self)
        UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: loginView)
    }
}

struct LoginView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State private var shouldVerifyToken = true
    
    fileprivate func SignInButton() -> Button<Text> {
        Button(action: {
            userAuth.signIn()
        }) {
            Text("Sign In")
        }
    }
    
    fileprivate func ProfilePic() -> some View {
        AsyncImage(url: URL(string: userAuth.profilePicUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        } placeholder: {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
        }
    }
    
    fileprivate func UserInfo() -> some View {
        return Text(userAuth.givenName)
            .font(.title)
            .fontWeight(.bold)
            .padding()
    }
    
    var body: some View {
        VStack {
            if userAuth.isLoggedIn && shouldVerifyToken { // Only verify token once
                verifyAccessToken()
                    .onDisappear { shouldVerifyToken = false } // Update the state to prevent further verification
            } else {
                Spacer()
                UserInfo()
                ProfilePic()
                if userAuth.isLoggedIn {
                    NavigationLink(destination: ContentView().environmentObject(userAuth)) {
                        Text("Home")
                    }
                } else {
                    SignInButton()
                }
            }
           
            Text(userAuth.errorMessage)
                .foregroundColor(.red)
            
            ForEach(0..<10) { _ in
                Circle()
                    .fill(Color.blue.opacity(0.35))
                    .frame(width: randomCircleSize(), height: randomCircleSize())
                    .position(x: randomCirclePosition(), y: randomCirclePosition())
                    .blur(radius: randomCircleBlur())
            }
        }
        .navigationTitle("Login")
    }
    
    private func verifyAccessToken() -> some View {
        // Verify the access token
        // Example: using URLSession
        let url = URL(string: "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=\(GIDSignIn.sharedInstance.currentUser?.idToken?.tokenString ?? "")")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                // Handle the error
                DispatchQueue.main.async {
                    userAuth.errorMessage = "Failed to verify access token: \(error.localizedDescription)"
                }
                return
            }

            if let data = data {
                // Parse the token verification response
                do {
                    let verificationResult = try JSONDecoder().decode(TokenVerificationResult.self, from: data)
                    if verificationResult.aud == "66603309185-k7bccilod9b8pqfk87ngdssgv6ep1da8.apps.googleusercontent.com" {
                        // Access token is valid and belongs to your app, proceed to HomeView
                        DispatchQueue.main.async {
                            let contentView = HomeView().environmentObject(userAuth)
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: contentView)
                        }
                    } else {
                        // Access token doesn't belong to your app, handle the sign-in flow again
                        DispatchQueue.main.async {
                            userAuth.errorMessage = "Invalid access token"
                            userAuth.signOut()
                        }
                    }
                } catch {
                    // Error parsing the token verification response
                    DispatchQueue.main.async {
                        userAuth.errorMessage = "Failed to verify access token"
                        userAuth.signOut()
                    }
                }
            }
        }
        task.resume()

        // Show a loading indicator while verifying the access token
        return ProgressView()
    }
    
    private func randomCircleSize() -> CGFloat {
        CGFloat.random(in: 50...200)
    }

    private func randomCirclePosition() -> CGFloat {
        CGFloat.random(in: -200...400)
    }

    private func randomCircleBlur() -> CGFloat {
        CGFloat.random(in: 0...20)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserAuthModel())
    }
}
