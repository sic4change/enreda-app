class FilterResource {
  String searchText;
  String resourceCategoryId;
  int limit; // Added for infinite scroll pagination support

  FilterResource(
      this.searchText,
      this.resourceCategoryId,
      {this.limit = 50});
}