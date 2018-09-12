# GitHub[MultipleEnvironment](https://github.com/leiguang/MultipleEnvironment)
### 本项目包含 “iOS app配置多环境变量  + 使用fastlane快速打包并上传蒲公英/AppStore”

> 参考
> - 基本概念请先阅读[iOS app配置多个环境变量](https://www.imooc.com/article/45288)
> - [使用fastlane快速打包并上传蒲公英/AppStore](https://www.pgyer.com/doc/view/fastlane)
> - [利用Jenkins持续集成iOS项目](https://www.jianshu.com/p/41ecb06ae95f)

---

### 需求：切换以下功能时无需修改代码
1. 切换服务器时。
2. 开发、测试环境下的 “分享、统计” 等功能 使用开发渠道统计数据，上线后才使用线上渠道统计。
3. 开发、测试环境显示全部功能，而正式上线时需服务端控制该功能的显示/隐藏（例如：躲避苹果的支付审核，测试环境下允许支付宝、微信、苹果内购 3种支付方式，而审核时只显示苹果内购支付）（注：千万不要试图躲避内购，否则苹果生气了后果很严重，亲身体验）

---

### 定义三个项目环境变量。
- dev: 开发
- adhoc: 测试
- appstore: 线上

---

### 可选方案：
1. 利用Build Configuration来配置多环境
2. 利用xcconfig文件来配置多环境
3. 利用Targets来配置多环境

---

### 配置步骤：
1. 根据本项目需求，采用最简单轻量级的方案 "Build Configuration" 来配置多环境。
2. 为 "dev", "adhoc", "appstore" 3种环境分别创建 Debug、Release版的Configuration。 
    1. 在Xcode的 Project 里面找到 Configurations。
    2. dev: 将"Debug"改名为"dev-debug"，将"Release"改名为"dev-release"，
    3. adhoc: 点击 "+"  -> "Duplicate Debug Configuration"，改名为 "adhoc-debug"，  再点击 "+" -> "Duplicate Release Configuration" 改名为 "adhoc-release"。  这里使用 Duplicate，如果项目已经安装过cocoapods，则会把对应 Debug、Release环境下的配置一并拷贝过来。
    4. appstore: 同"adhoc"。
    注意：如果使用了cocoapods，完成后需要pod install一下。
    ![configurations_1](https://github.com/leiguang/MultipleEnvironment/blob/master/resources/configurations_1.png)
    ![configurations_2](https://github.com/leiguang/MultipleEnvironment/blob/master/resources/configurations_2.png)
3. 选中 "对应的Target" -> "Build Settings" -> "Active Compilation Conditions(Swift版，如果是OC，则是Preprocessor Macros)" 为不同环境配置不同的宏定义。（系统默认已在Debug环境下带有“DEBUG”标志）
    1. dev-debug: DEBUG dev
    2. dev-release: dev
    3. adhoc-debug: DEBUG adhoc 
    4. adhoc-release: adhoc
    5. appstore-debug: DEBUG appstore
    6. appstore-release: appstore
    
    这样做比较灵活，项目中就可以自由组合 DEBUG、dev、adhoc、appstore 来判断环境条件了。
    
    ![compilation_conditions](https://github.com/leiguang/MultipleEnvironment/blob/master/resources/compilation_conditions.png)
4. 配置Scheme。
    1. 新建3个Scheme，"New Scheme", 名字可以为“工程名+ dev、adhoc、appstore等后缀”，自己看得懂就行。
    2. 创建后要勾选shared选项，这样该scheme才会加入到git中，与他人共享，然后可以删掉最开始那个无用的Scheme了。
    3. "Edit Scheme"，需要为每个Scheme的 "Run", "Test", "Archive"... 之类的  配置 "Build Configuration"，按需选则对应的。
            例如 系统默认对应的 Debug、Release如下
            dev: "Run" - "dev-debug"
                    "Test" - "dev-debug"
                    "Profile" - "dev-release"
                    "Analyze" - "dev-debug"
                    "Archive" - "dev-release"
    ![scheme_1](https://github.com/leiguang/MultipleEnvironment/blob/master/resources/scheme_1.png)
    ![scheme_2](https://github.com/leiguang/MultipleEnvironment/blob/master/resources/scheme_2.png)
   
---
                
### 代码中的使用：
1. 配置不同服务器地址
```
#if dev
let ServerURL = "http://aaa.com"
#elseif adhoc
let ServerURL = "http://bbb.com"
#elseif appstore
let ServerURL = "http://ccc.com"
#endif
```
2. 开发、测试环境下，配置渠道。
```
#if dev || adhoc
channel = "development"
#else
channel = "appstore"
#endif
```
3. Debug && dev环境下添加额外功能
```
#if DEBUG && dev 
// add some feature 
#endif
```

---

### 使用：
需要切换环境时，直接选中对应的Scheme，run就好了。

---

### 补充：
如果想在同一部手机上安装多个不同环境下的相同App，可选择 "对应Target" -> "Build Settings" -> "+" -> "Add User-Defined Setting" 为不同Scheme配置不同包名、应用名、应用图标等，但是要注意，如果App里中有和 包名bundle Id相关的配置，则要小心了，例如推送证书，它指定推送到对应bundle id的应用上（亲身踩坑）。 此时简单的使用 "Build Configuration" 则无法满足需求，可选择 多Targets来配置多环境、多证书之类。

---

### fastlane自动打包上传
[使用fastlane快速打包并上传蒲公英/AppStore](https://www.pgyer.com/doc/view/fastlane)这篇文章写得非常清晰详细了。我的fastlane配置文件已经在项目中了 /fastlane/Fastfile。更多fastlane的actions信息可以在[fastlane actions文档](https://docs.fastlane.tools/actions)中查看
在项目根目录下使用：
- "fastlane dev": 打开发环境的包并上传蒲公英
- "fastlane adhoc": 打测试环境的包并上传蒲公英
- "fastlane release": 打正式包并提交到"https://appstoreconnect.apple.com"上。
        其中 "fastlane release"正式包还需配置/fastlane/Appfile中的 "App Store Connect Team ID"和"Developer Portal Team ID"。（注意这里使用 release而不是appstore字段，是因为appstore字段已经被fastlane作为其他用途了）

补充：打包后，在项目根目录下会出现 ipa包，它已被.gitignore忽略，并且 每次打新包都会自动覆盖旧ipa包。通过fastlane打的包也会出现在 Xcode的Organizer中.
       
---
        
### 使用Jenkins持续集成
本项目未使用，可参阅[利用Jenkins持续集成iOS项目](https://www.jianshu.com/p/41ecb06ae95f)
