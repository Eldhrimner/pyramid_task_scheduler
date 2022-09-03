local CommonPipeline = {
  kind: 'pipeline',
  type: 'docker',
  name: 'common-checks',
  steps: [
    {
      name: 'common-checks',
      image: 'python',
      commands: [
        'echo hello world',
        'pip install flake8 black',
        'flake8 .',
        'black --diff .',
        'black --check .',
      ],
    },
  ],
};

local PythonVersionsPipeline(name, image) = {
  kind: 'pipeline',
  name: name,
  steps: [
    {
      name: 'test',
      image: image,
      commands: [
        'pip3 install .',
      ],
    },
  ],
};

local BuildAndPublishPipline() = {
  kind: 'pipline',
  name: 'build and publish',
  steps: [
    {
      name: 'build',
      image: 'python',
      commands: [
        'python3 -m build',
      ],
    },
    {
      name: 'pypi_publish',
      image: 'plugins/pypi',
      settings: {
        username: { from_secret: 'pypi_username' },
        password: { from_secret: 'pypi_password' },
      },
      when: {
        event: 'promote',
      },
    },
  ],
};

[CommonPipeline()] +
[
  PythonVersionsPipeline('python-3-6', 'python:3.6'),
  PythonVersionsPipeline('python-3-7', 'python:3.7'),
  PythonVersionsPipeline('python-3-8', 'python:3.8'),
  PythonVersionsPipeline('python-3-9', 'python:3.9'),
  PythonVersionsPipeline('python-3-10', 'python:3.10'),
] +
[BuildAndPublishPipline()]
