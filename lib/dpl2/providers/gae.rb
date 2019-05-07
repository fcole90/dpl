module Dpl
  module Providers
    class Gae < Provider
      summary 'Gae deployment provider'

      experimental 'Google App Engine'

      description <<~str
        tbd
      str

      env :googlecloud, :cloudsdk_core

      opt '--project ID', 'Project ID used to identify the project on Google Cloud', required: true
      opt '--keyfile FILE', 'Path to the JSON file containing your Service Account credentials in JSON Web Token format. To be obtained via the Google Developers Console. Should be handled with care as it contains authorization keys.', default: 'service-account.json'
      opt '--config FILE', 'Path to your module configuration file', default: 'app.yaml'
      opt '--version VER', 'The version of the app that will be created or replaced by this deployment. If you do not specify a version, one will be generated for you'
      opt '--verbosity LEVEL', 'Adjust the log verbosity', default: 'warning'
      opt '--no_promote', 'Do not promote the deployed version'
      opt '--no_stop_previous_version', 'Prevent your deployment from stopping the previously promoted version. This is from the future, so might not work (yet).'

      CMDS = {
        login:     '~/google-cloud-sdk/bin/gcloud -q auth activate-service-account --key-file %{keyfile}',
        validate:  'python -c "import sys; print(sys.version)"',
        install:   'curl -L https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz | gzip -d | tar -x -C ~',
        bootstrap: '~/google-cloud-sdk/bin/bootstrapping/install.py --usage-reporting=false --command-completion=false --path-update=false',
        cat_logs:  'find $HOME/.config/gcloud/logs -type f -print -exec cat {} \;'
      }

      ASSERT = {
        login:     'Failed to authentication.',
        validate:  'Failed to use Python 2.7',
        install:   'Failed to download Google Cloud SDK.',
        bootstrap: 'Failed bootstrap Google Cloud SDK.',
      }

      MSGS = {
        validate:  'Python 2.7 Version',
        install:   'Downloading Google Cloud SDK ...',
        bootstrap: 'Bootstrapping Google Cloud SDK ...',
        failed:    'Deployment failed.',
      }

      def install
        return if which 'gcloud'
        validate_python_2_7
        install_sdk
        bootstrap_sdk
      end

      def login
        shell :login, python: 2.7, assert: true
      end

      def deploy
        shell deploy_cmd, python: 2.7
        deploy_failed unless success?
      end

      private

        def validate_python_2_7
          info :validate
          shell :validate, python: 2.7, assert: true
        end

        def install_sdk
          info :install
          shell :install, assert: true
        end

        def bootstrap_sdk
          info :bootstrap
          shell :bootstrap, python: 2.7, assert: true
        end

        def deploy_cmd
          cmd = '~/google-cloud-sdk/bin/gcloud --quiet '
          cmd << opts_for(%i(verbosity project config version))
          cmd << " --#{no_promote? ? 'no-' : ''}promote"
          cmd << ' --no-stop-previous-version' if no_stop_previous_version?
          cmd
        end

        def deploy_failed
          warn :failed
          shell :cat_logs
          error ''
        end

        def project
          super || File.dirname(build_dir)
        end
    end
  end
end
