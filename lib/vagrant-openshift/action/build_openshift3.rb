#--
# Copyright 2013 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#++

module Vagrant
  module Openshift
    module Action
      class BuildOpenshift3
        include CommandHelper

        def initialize(app, env, options)
          @app = app
          @env = env
          @options = options
        end

        def call(env)
          if @options[:images]
            cmd = %{
echo "Performing openshift release build..."
set -e
hack/verify-gofmt.sh
hack/build-release.sh
hack/build-images.sh
if [ ! -d _output/etcd ]
then
  hack/install-etcd.sh
fi
}
          else
            cmd = %{
echo "Performing openshift build..."
set -e
hack/verify-gofmt.sh
hack/build-go.sh
if [ ! -d _output/etcd ]
then
  hack/install-etcd.sh
fi
}
          end
          unless @options[:force]
            cmd = sync_bash_command('origin', cmd)
          end
          do_execute(env[:machine], cmd)

          @app.call(env)
        end

      end
    end
  end
end