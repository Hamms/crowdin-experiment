Rails.application.routes.draw do
  scope "(:locale)" do
    resources :posts, param: :slug
    root 'posts#index'
  end

  get '/:locale' => 'posts#index'
end
