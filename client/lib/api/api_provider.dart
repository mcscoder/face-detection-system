class ApiProviderOption {
  const ApiProviderOption({required this.label, required this.baseUrl});

  final String label;
  final Uri baseUrl;
}

final apiProviderOptions = [
  ApiProviderOption(
    label: 'DDNS',
    baseUrl: Uri.parse('http://theunseenblade.ddns.net:8000'),
  ),
  ApiProviderOption(
    label: 'Ngrok',
    baseUrl: Uri.parse('https://subtepid-setsuko-canthal.ngrok-free.dev'),
  ),
];

ApiProviderOption apiProviderForUrl(String? url) {
  return apiProviderOptions.firstWhere(
    (provider) => provider.baseUrl.toString() == url,
    orElse: () => apiProviderOptions.first,
  );
}
