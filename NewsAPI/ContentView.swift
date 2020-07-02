//
//  ContentView.swift
//  NewsAPI
//
//  Created by Võ Thanh Sang on 6/30/20.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    
    @ObservedObject var list = getData()
    
    var body: some View {
        
        NavigationView {
            
            List(list.datas) { i in
                
                NavigationLink(
                    destination: webView(url: i.url),
                    label: {
                        HStack{
                            
                            VStack {
                                Text(i.title).fontWeight(.heavy)
                                Text(i.desc).lineLimit(3)
                                
                            }.padding(.leading)
                            
                            if i.image != "" {
                                WebImage(url: URL(string: i.image)!, options: .highPriority, context: nil)
                                    .resizable()
                                    .frame(width: 110, height: 135)
                                    .cornerRadius(20)
                            }
                        }.padding(.vertical, 10)
                    })
            }
            .navigationBarTitle("HeadTitle")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct dataType: Identifiable {
    var id: String
    var title: String
    var desc: String
    var url: String
    var image: String
}

class getData: ObservableObject {
    
    @Published var datas = [dataType]()
    
    init() {
        let source = "http://newsapi.org/v2/everything?q=apple&from=2020-06-29&to=2020-06-29&sortBy=popularity&apiKey=576e0da074b4457ca735f9feef015f82"
        
        let url = URL(string: source)!
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, url, error) in
            if error != nil {
                print("LOLLLLL\(error?.localizedDescription)")
                return
            }
            
            let json = try! JSON(data: data!)
            
            for i in json["articles"] {
                
                let title = i.1["title"].stringValue
                let description = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                DispatchQueue.main.async {
                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
                }
            }
        }.resume()
    }
}

struct webView: UIViewRepresentable {
    var url: String
    
    func makeUIView(context: UIViewRepresentableContext<webView>) -> WKWebView {
        
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
        
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
        
    }
}
