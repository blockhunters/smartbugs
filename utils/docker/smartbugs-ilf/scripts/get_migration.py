import click
import jinja2


CONSTRUCTOR_0_4_23 = """
  constructor() public {
    owner = msg.sender;
  }
"""

CONSTRUCTOR_0_4_22 = """
  function Migration public {
      owner = msg.sender;
  }
"""

templateEnv = jinja2.Environment(loader=jinja2.FileSystemLoader(searchpath="/workdir/scripts/"))
TEMPLATE_FILE = "Migrations.sol.jinja"
template = templateEnv.get_template(TEMPLATE_FILE)


def pre_0_4_23(version):
  splitted = version.split('.')
  less_than_0_4 = splitted[0] == "0" and int(splitted[1]) < 4
  less_than_0_4_22 = version.startswith('0.4.') and (int(splitted[2]) <= 22)
  return less_than_0_4 or less_than_0_4_22


@click.command()
@click.argument('solc_version')
def render_migration(solc_version):
  constructor = CONSTRUCTOR_0_4_22 if pre_0_4_23(solc_version) else CONSTRUCTOR_0_4_23
  click.echo(template.render(solc_version=solc_version, constructor=constructor))


if __name__ == '__main__':
  render_migration()
