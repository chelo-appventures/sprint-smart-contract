import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JAN_1ST_2030 = 1893456000;
const ONE_GWEI: bigint = 1_000_000_000n;

const SprintModule = buildModule("SprintModule", (m) => {
  const customer = m.getParameter("comprador", "");
  const provider = m.getParameter("vendedor", ONE_GWEI);
  const agent = m.getParameter("agente", ONE_GWEI);
  const amount = m.getParameter("monto", ONE_GWEI);
  const start = m.getParameter("inicio", ONE_GWEI);
  const end = m.getParameter("fin", ONE_GWEI);
  const document = m.getParameter("documento", ONE_GWEI);

  const sprint = m.contract("Sprint", [
    customer,
    provider,
    agent,
    amount,
    start,
    end,
    document,
  ]);

  return { sprint };
});

export default SprintModule;
