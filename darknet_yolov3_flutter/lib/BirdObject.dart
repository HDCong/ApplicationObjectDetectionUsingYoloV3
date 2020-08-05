class BirdObject{
  final int index;
  final String mLink;
  final String mContent;
  final String mName;
  BirdObject(this.index,this.mName,this.mLink, this.mContent);
  bool isEqual(BirdObject model) {
    print('is equal object');
    return this?.mName.toLowerCase().contains(model?.mName.toLowerCase()) || this?.mContent.toLowerCase().contains(model?.mContent.toLowerCase());
  }
  bool isFiltered(String s){
    return mContent.toLowerCase().contains(s.toLowerCase());
  }
  @override
  String toString() {
    return  mName;
  }
}
