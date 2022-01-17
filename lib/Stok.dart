class Stok {
  int? id;
  int? id_barang;
  int? total_barang;
  String? jenis_stok;

  Stok(
      {this.id,
        this.id_barang,
        this.total_barang,
        this.jenis_stok});

  Stok.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    id_barang = json['id_barang'];
    total_barang = json['total_barang'];
    jenis_stok = json['jenis_stok'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['id_barang'] = this.id_barang;
    data['total_barang'] = this.total_barang;
    data['jenis_stok'] = this.jenis_stok;
    return data;
  }
}