
shared_examples_for "an authenticated action" do
  it "blocks unauthenticated access" do
    no_sign_in
    action
    expect(response.status).to eq 401
  end
  it "allows 'end_user' access" do
    sign_in_as :end_user
    action
    expect(response).to be_success
  end
  it "allows 'agent' access" do
    sign_in_as :agent
    action
    expect(response).to be_success
  end
  it "allows 'admin' access" do
    sign_in_as :admin
    action
    expect(response).to be_success
  end
end

shared_examples_for "an agent-restricted action" do
  it "blocks unauthenticated access" do
    no_sign_in
    action
    expect(response.status).to eq 401
  end
  it "blocks 'end_user' access" do
    sign_in_as :end_user
    action
    expect(response.status).to eq 403
  end
  it "allows 'agent' access" do
    sign_in_as :agent
    action
    expect(response).to be_success
  end
  it "allows 'admin' access" do
    sign_in_as :admin
    action
    expect(response).to be_success
  end
end

shared_examples_for "an admin-restricted action" do
  it "blocks unauthenticated access" do
    no_sign_in
    action
    expect(response.status).to eq 401
  end
  it "blocks 'end_user' access" do
    sign_in_as :end_user
    action
    expect(response.status).to eq 403
  end
  it "blocks 'agent' access" do
    sign_in_as :agent
    action
    expect(response.status).to eq 403
  end
  it "allows 'admin' access" do
    sign_in_as :admin
    action
    expect(response).to be_success
  end
end



