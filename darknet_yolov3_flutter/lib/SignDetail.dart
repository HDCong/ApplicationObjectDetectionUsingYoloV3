class SignDetail{
  final int index;
  final String mLink;
  final String mContent;
  SignDetail(this.index,this.mLink, this.mContent);
  bool isEqual(SignDetail model) {
    print('is equal object');
    return _getNameSign(this?.mLink) == _getNameSign(model?.mLink) || this?.mContent.contains(model?.mContent);
  }
  String _getNameSign(String imgLink) {
    return imgLink.substring(48, imgLink.indexOf(".png"));
  }


  bool isFiltered(String s){
    return mContent.contains(s);
  }
  @override
  String toString() {
    return  'Biển số: '+_getNameSign(mLink);
  }
}
