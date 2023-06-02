class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent({required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Mobile Point of Sale',
      image: 'assets/images/mps.jpg',
      discription: "Sell from phone or tablet, issue your printed or eletronic receipts, "
          "accept multiple payments methods and much more."
  ),
  UnbordingContent(
      title: 'Sales & Purchase',
      image: 'assets/images/sale.jpg',
      discription: "You can have a better look of your sales and purchase using Sellio. "
          "You can get sale return list, purchase list and can have purchase due invoice. "

  ),
  UnbordingContent(
      title: 'Balance Sheets & Reports',
      image: 'assets/images/r.png',
      discription: "You can have reports, can manage balance sheets, can have record of previous one."
          "You will have report collection, report after due paid"
  ),
];