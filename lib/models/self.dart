class Self {
  var phoneNumber;
  var phoneNnumberWithoutCountry;
  var l;
  var j;
  var k;
  Self(
      {this.phoneNnumberWithoutCountry,
      this.phoneNumber,
      this.l,
      this.k,
      this.j});

  Map toSelf() {
    return {
      'phoneNumber': phoneNumber,
      'phoneNnumberWithoutCountry': phoneNnumberWithoutCountry
    };
  }

  Map indexes() {
    return {
      'l': l,
      'k': k,
      'j': j,
    };
  }
}
