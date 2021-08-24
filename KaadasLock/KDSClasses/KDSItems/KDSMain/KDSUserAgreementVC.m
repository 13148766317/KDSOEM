//
//  KDSUserAgreementVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSUserAgreementVC.h"
#import "MBProgressHUD+MJ.h"

@interface KDSUserAgreementVC ()

@end

@implementation KDSUserAgreementVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"userAgreement");
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    [self setRightButton];
    UITextView *textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.selectable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeNone;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.attributedText = [self zhSimple];
    textView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (NSAttributedString *)zhSimple
{
    NSString *content = @"\n\n本协议系深圳市凯迪仕智能科技有限公司与所有使用智开智能客户端（以下简称“智开智能”）的主体（包含但不限于个人、团队等）（以下简称用户）所订立的有效合约。使用智开智能的任何服务即表示接受本协议的全部条款。\n\n一、总则\n1.1 智开智能的所有权和运营权归深圳市凯迪仕智能科技有限公司。\n1.2 用户在注册之前，应当仔细阅读本协议，并同意遵守本协议后方可成为注册用户。一旦注册成功，系，用户应当受本协议的约束。用户在使用特殊的服务或产品时，应当同意接受相关协议后方能使用。\n\n二、服务内容及使用须知\n2.1 智开智能仅提供相关的网络服务，除此之外与相关网络服务有关的设备(如个人电脑、手机、及其他与接入互联网或移动网有关的装置)及所需的费用(如为接入互联网而支付的电话费及上网费、为使用移动网而支付的手机费)均应由用户自行负担。\n\n三、用户账号\n3.1 经智开智能注册系统完成注册程序并通过身份认证的用户即成为正式用户，可以获得规定用户所应享有的一切权限。\n3.2 用户通过该账号所进行的一切活动引起的任何损失或损害，由用户自行承担全部责任，智开智能不承担任何责任。因黑客行为或用户的保管疏忽导致账号非法使用，智开智能不承担任何责任。\n\n四、使用规则\n4.1 用户需遵守中华人民共和国相关法律法规，包括但不限于《中华人民共和国计算机信息系统安全保护条例》、《计算机软件保护条例》、《最高人民法院关于审理涉及计算机网络著作权纠纷案件适用法律若干问题的解释(法释[2004]1号)》、《全国人大常委会关于维护互联网安全的决定》、《互联网电子公告服务管理规定》、《互联网新闻信息服务管理规定》、《互联网著作权行政保护办法》和《信息网络传播权保护条例》等有关计算机互联网规定和知识产权的法律和法规、实施办法。\n4.2 用户对其自行发表、上传或传送的内容负全部责任，所有用户不得在智开智能任何页面发布、转载、传送含有下列内容之一的信息，否则智开智能有权自行处理并不通知用户，且由此引起的任何损失或损害，由用户自行承担全部责任，智开智能不承担任何责任：\n(1)违反宪法确定的基本原则的；\n(2)危害国家安全，泄漏国家机密，颠覆国家政权，破坏国家统一的；\n(3)损害国家荣誉和利益的；\n(4)煽动民族仇恨、民族歧视，破坏民族团结的；\n(5)破坏国家宗教政策，宣扬邪教和封建迷信的；\n(6)散布谣言，扰乱社会秩序，破坏社会稳定的；\n(7)散布淫秽、色情、赌博、暴力、恐怖或者教唆犯罪的；\n(8)侮辱或者诽谤他人，侵害他人合法权益的；\n(9)煽动非法集会、结社、游行、示威、聚众扰乱社会秩序的；\n(10)以非法民间组织名义活动的；\n(11)含有法律、行政法规禁止的其他内容的。\n4.3 用户承诺对其发表或者上传于智开智能的所有信息(即属于《中华人民共和国著作权法》规定的作品，包括但不限于文字、图片、音乐、电影、表演和录音录像制品和电脑程序等)均享有完整的知识产权，或者已经得到相关权利人的合法授权；如用户违反本条规定造成智开智能被第三人索赔的，由用户自行承担全部责任；\n4.4 用户保证，其向智开智能上传的内容不得直接或间接的：\n(1)为任何非法目的而使用网络服务系统；\n(2)以任何方式干扰或企图干扰智开智能客户端\n(3)避开、尝试避开或声称能够避开任何内容保护机制或者智开智能数据度量工具；\n(4)请求、收集、索取或以其他方式从任何用户那里获取对智开智能账号、密码或其他身份验证凭据的访问权；\n(5)为任何用户自动登录到智开智能账号代理身份验证凭据；\n(6)提供跟踪功能，包括但不限于识别其他用户在个人主页上查看或操作；\n (7)未经授权冒充他人获取对智开智能的访问权。\n4.5 用户违反上述任何一款的保证，智开智能均有权就其情节对其做出警告、屏蔽直至取消登录资格的处罚；如因用户违反上述保证而给智开智能用户造成损失，用户自行负责承担一切法律责任并赔偿损失。\n\n五、隐私保护\n5.1 智开智能不对外公开或向第三方提供单个用户的注册资料及用户在使用网络服务时存储在智开智能的非公开内容，但下列情况除外：\n(1)事先获得用户的明确授权；\n(2)根据有关的法律法规要求；\n(3)按照相关政府主管部门的要求；\n(4)为维护社会公众的利益。\n5.2 智开智能可能会与第三方合作向用户提供相关的网络服务，在此情况下，如该第三方同意承担与智开智能同等的保护用户隐私的责任，则智开智能有权将用户的注册资料等提供给该第三方。\n5.3 在不透露单个用户隐私资料的前提下，智开智能有权对整个用户数据库进行分析并对用户数据库进行商业上的利用。\n\n六、责任声明\n6.1 用户明确同意其使用智开智能网络服务所存在的风险及一切后果将完全由用户本人承担。\n6.2 智开智能无法保证网络服务一定能满足用户的要求，也不保证网络服务的及时性、安全性、准确性。\n6.3 智开智能不保证为方便用户而设置的外部链接的准确性和完整性，同时，对于该等外部链接指向的不由智开智能实际控制的任何网页上的内容，智开智能不承担任何责任。\n6.4对于智开智能向用户提供的下列产品或者服务的质量缺陷本身及其引发的任何损失，智开智能无需承担任何责任：\n(1)智开智能向用户免费提供的各项网络服务；\n(2) 智开智能向用户赠送的任何产品或者服务。\n6.5 智开智能有权于任何时间暂时或永久修改或终止本服务(或其任何部分)，而无论其通知与否，智开智能对用户和任何第三人均无需承担任何责任。\n\n七、附则\n7.1 本协议的订立、执行和解释及争议的解决均应适用中华人民共和国法律。如用户和优点科技就本协议内容或其执行发生任何争议，双方应尽量友好协商解决；协商不成时，任何一方均可向凯迪仕所在地的人民法院提起诉讼。\n7.2本协议一经公布即生效，凯迪仕有权随时对协议内容进行修改，如果用户继续使用网络服务，则视为用户接受对本协议相关条款所做的修改。 \n7.3 如本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，本协议的其余条款仍应有效并且有约束力。\n7.4不可抗力条款：如果不能履行本协议是由于一方所不能预见和控制的原因造成的，如战争、罢工、自然灾害、恶劣天气、航空运输中断等，则不能履行本协议的一方可相应免责。\n7.5 本协议解释权及修订权归深圳市凯迪仕智能科技有限公司。";

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    style.firstLineHeadIndent = style.headIndent = 10;
    style.tailIndent = -10;
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:17], NSForegroundColorAttributeName:UIColor.blackColor, NSParagraphStyleAttributeName:style};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:style}];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"一、总则"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"二、服务内容及使用须知"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"三、用户账号"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"四、使用规则"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"五、隐私保护"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"六、责任声明"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"七、附则"]];
    
    return attrStr;
}

@end
