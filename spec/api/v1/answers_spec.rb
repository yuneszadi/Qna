require "rails_helper"

 describe 'Answers API' do
  let!(:question) { create(:question) }
  let(:access_token) { create(:access_token) }
  let!(:answers) { create_list(:answer, 2, question: question) }
  let!(:answer) { answers.first }

  describe 'GET /index' do
    context 'Unauthorized' do
      it 'returns 401 status if there is no access_token' do
        get "/api/v1/questions/#{question.id}/answers", params: { format: :json }
        expect(response).to have_http_status(401)
      end

      it '- returns 401 status if access_token is invalid' do
        get "/api/v1/questions/#{question.id}/answers", params: { access_token: '1234', format: :json }
        expect(response).to have_http_status(401)
      end
    end

    context 'Authorized' do

      before { get "/api/v1/questions/#{question.id}/answers", params: { format: :json, access_token: access_token.token} }
      it 'returns 200 status' do
        expect(response).to have_http_status(200)
      end

      %w[id body user_id created_at updated_at].each do |attr|
        it "answer object contains #{attr}" do
          expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("0/#{attr}")
        end
      end
    end
  end

  describe 'GET /show' do
    let!(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question) }
    let!(:comments) { create_list(:comment, 2, commentable: answer) }
    let(:comment) { comments.first }
    let!(:attachments) { create_list(:attachment, 2, attachable: answer) }
    let(:attachment) { attachments.first }

    context 'Unauthorized' do
      it 'returns 401 status if there is no access_token' do
        get "/api/v1/answers/#{answer.id}", params: { format: :json }
        expect(response).to have_http_status(401)
      end

      it 'returns 401 status if access_token is invalid' do
        get "/api/v1/answers/#{answer.id}", params: { access_token: '1234', format: :json }
        expect(response).to have_http_status(401)
      end
    end
    context 'Authorized' do
      let(:access_token) { create(:access_token) }

       before { get "/api/v1/answers/#{answer.id}", params: { format: :json, access_token: access_token.token } }

       it 'returns 200 status' do
        expect(response).to have_http_status(200)
      end

      context 'contains' do
        %w[id body user_id created_at updated_at].each do |attr|
          it "- #{attr}" do
            expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("#{attr}")
          end
        end
      end

      context 'attachments ' do
        it 'included in answer object' do
          expect(response.body).to have_json_size(attachments.size).at_path('attachments')
        end

        it 'contains url' do
          expect(response.body).to be_json_eql(attachment.file.url.to_json).at_path('attachments/0/url')
        end
      end

      context 'comments' do
        it 'included in answer object' do
          expect(response.body).to have_json_size(comments.size).at_path('comments')
        end

        %w[id body user_id].each do |attr|
          it "- contains #{attr}" do
            expect(response.body).to be_json_eql(comment.send(attr.to_sym).to_json).at_path("comments/0/#{attr}")
          end
        end
      end
    end
  end

  describe 'POST /create' do
    let(:user) { create(:user) }
    let(:access_token) { create(:access_token, resource_owner_id: user.id) }
    let(:attrs) { attributes_for(:answer, user: user) }

    context 'Unauthorized' do
      it 'returns 401 status if there is no access_token' do
        post "/api/v1/questions/#{question.id}/answers", params: { format: :json }
        expect(response).to have_http_status(401)
      end

      it 'returns 401 status if access_token is invalid' do
        post "/api/v1/questions/#{question.id}/answers", params: { access_token: '1234', format: :json }
        expect(response).to have_http_status(401)
      end
    end

    context 'authorized' do
      before { post "/api/v1/questions/#{question.id}/answers", params: { access_token: access_token.token, answer: attrs, format: :json } }

      it 'successful' do
        expect(response).to have_http_status(200)
      end

      %w[body user_id created_at updated_at attachments comments].each do |attr|
        it "contains #{attr}" do
          expect(response.body).to have_json_path(attr)
        end
      end

      it "set body" do
        expect(response.body).to be_json_eql(attrs[:body].to_json).at_path('body')
      end

      it 'set user_id' do
        expect(response.body).to be_json_eql(user.id.to_json).at_path('user_id')
      end
    end
  end
end
