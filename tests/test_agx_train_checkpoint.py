import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from agx_offline_qlora_train import latest_valid_checkpoint


def test_latest_valid_skips_incomplete(tmp_path: Path):
    (tmp_path / "checkpoint-100").mkdir()
    (tmp_path / "checkpoint-100" / "trainer_state.json").write_text("{}")
    broken = tmp_path / "checkpoint-150"
    broken.mkdir()
    (broken / "optimizer.pt").write_bytes(b"x")
    assert latest_valid_checkpoint(tmp_path) == tmp_path / "checkpoint-100"
