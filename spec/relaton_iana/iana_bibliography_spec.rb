RSpec.describe RelatonIana::IanaBibliography do
  it "raise RequestError" do
    expect(Relaton::Index).to receive(:find_or_create).and_raise(SocketError)
    # expect(Net::HTTP).to receive(:get_response).and_raise(SocketError)
    expect do
      RelatonIana::IanaBibliography.get "ref"
    end.to raise_error RelatonBib::RequestError
  end
end
