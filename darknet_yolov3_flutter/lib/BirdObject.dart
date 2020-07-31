class BirdObject{
  final int index;
  final String mLink;
  final String mContent;
  final String mName;
  BirdObject(this.index,this.mName,this.mLink, this.mContent);
  bool isEqual(BirdObject model) {
    print('is equal object');
    return this?.mName.contains(model?.mName) || this?.mContent.contains(model?.mContent);
  }
  bool isFiltered(String s){
    return mContent.contains(s);
  }
  @override
  String toString() {
    return  mName;
  }
}
